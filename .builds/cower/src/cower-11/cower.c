/* Copyright (c) 2010-2011 Dave Reisner
 *
 * cower.c
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

/* glibc */
#define _GNU_SOURCE
#include <ctype.h>
#include <errno.h>
#include <fnmatch.h>
#include <getopt.h>
#include <locale.h>
#include <pthread.h>
#include <pwd.h>
#include <regex.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <wchar.h>
#include <wordexp.h>

/* external libs */
#include <alpm.h>
#include <archive.h>
#include <archive_entry.h>
#include <curl/curl.h>
#include <openssl/crypto.h>
#include <yajl/yajl_parse.h>

/* macros */
#define UNUSED                __attribute__((unused))
#define NCFLAG(val, flag)     (!cfg.color && (val)) ? (flag) : ""

#ifndef PACMAN_ROOT
	#define PACMAN_ROOT         "/"
#endif
#ifndef PACMAN_DBPATH
	#define PACMAN_DBPATH       "/var/lib/pacman"
#endif
#ifndef PACMAN_CONFIG
	#define PACMAN_CONFIG       "/etc/pacman.conf"
#endif

#define AUR_BASE_URL          "https://aur.archlinux.org"
#define AUR_PKG_URL_FORMAT    AUR_BASE_URL "/packages/"
#define AUR_RPC_URL           AUR_BASE_URL "/rpc.php?type=%s&arg=%s"

#define NC                    "\033[0m"
#define BOLD                  "\033[1m"

#define BLACK                 "\033[0;30m"
#define RED                   "\033[0;31m"
#define GREEN                 "\033[0;32m"
#define YELLOW                "\033[0;33m"
#define BLUE                  "\033[0;34m"
#define MAGENTA               "\033[0;35m"
#define CYAN                  "\033[0;36m"
#define WHITE                 "\033[0;37m"
#define BOLDBLACK             "\033[1;30m"
#define BOLDRED               "\033[1;31m"
#define BOLDGREEN             "\033[1;32m"
#define BOLDYELLOW            "\033[1;33m"
#define BOLDBLUE              "\033[1;34m"
#define BOLDMAGENTA           "\033[1;35m"
#define BOLDCYAN              "\033[1;36m"
#define BOLDWHITE             "\033[1;37m"

#define BRIEF_ERR             "E"
#define BRIEF_WARN            "W"
#define BRIEF_OK              "S"

/* typedefs and objects */
typedef enum __loglevel_t {
	LOG_INFO    = 1,
	LOG_ERROR   = (1 << 1),
	LOG_WARN    = (1 << 2),
	LOG_DEBUG   = (1 << 3),
	LOG_VERBOSE = (1 << 4),
	LOG_BRIEF   = (1 << 5)
} loglevel_t;

typedef enum __operation_t {
	OP_SEARCH   = 1,
	OP_INFO     = (1 << 1),
	OP_DOWNLOAD = (1 << 2),
	OP_UPDATE   = (1 << 3),
	OP_MSEARCH  = (1 << 4)
} operation_t;

enum {
	OP_DEBUG = 1000,
	OP_FORMAT,
	OP_SORT,
	OP_RSORT,
	OP_IGNOREPKG,
	OP_IGNOREREPO,
	OP_LISTDELIM,
	OP_THREADS,
	OP_TIMEOUT,
	OP_VERSION,
	OP_NOIGNOREOOD
};

enum {
	KEY_CATEGORY,
	KEY_DESCRIPTION,
	KEY_FIRSTSUB,
	KEY_ID,
	KEY_LASTMOD,
	KEY_LICENSE,
	KEY_MAINTAINER,
	KEY_NAME,
	KEY_VOTES,
	KEY_OOD,
	KEY_URL,
	KEY_URLPATH,
	KEY_VERSION,
	KEY_QUERY_RESULTCOUNT,
	KEY_QUERY_RESULTS,
};

enum {
	SORT_FORWARD = 1,
	SORT_REVERSE = -1
};

typedef enum __pkgdetail_t {
	PKGDETAIL_DEPENDS = 0,
	PKGDETAIL_MAKEDEPENDS,
	PKGDETAIL_OPTDEPENDS,
	PKGDETAIL_PROVIDES,
	PKGDETAIL_CONFLICTS,
	PKGDETAIL_REPLACES,
	PKGDETAIL_MAX
} pkgdetail_t;

struct key_t {
	int id;
	const char *name;
};

struct strings_t {
	const char *error;
	const char *warn;
	const char *info;
	const char *pkg;
	const char *repo;
	const char *url;
	const char *ood;
	const char *utd;
	const char *nc;
};

struct aurpkg_t {
	char *desc;
	char *lic;
	char *maint;
	char *name;
	char *url;
	char *urlpath;
	char *ver;
	int cat;
	int id;
	int ood;
	int votes;
	time_t firstsub;
	time_t lastmod;
	alpm_list_t *conflicts;
	alpm_list_t *depends;
	alpm_list_t *makedepends;
	alpm_list_t *optdepends;
	alpm_list_t *provides;
	alpm_list_t *replaces;
};

struct yajl_parser_t {
	alpm_list_t *pkglist;
	int resultcount;
	struct aurpkg_t *aurpkg;
	int key;
	int json_depth;
	char *error;
};

struct response_t {
	char *data;
	size_t size;
};

struct task_t {
	void *(*threadfn)(CURL*, void*);
	void (*printfn)(struct aurpkg_t*);
};

struct openssl_mutex_t {
	pthread_mutex_t *lock;
	long *lock_count;
};

/* function prototypes */
static inline int streq(const char *, const char *);
static inline int startswith(const char *, const char *);
static alpm_list_t *alpm_find_foreign_pkgs(void);
static alpm_handle_t *alpm_init(void);
static int alpm_pkg_is_foreign(alpm_pkg_t*);
static const char *alpm_provides_pkg(const char*);
static int archive_extract_file(const struct response_t*, char**);
static int aurpkg_cmpver(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2);
static int aurpkg_cmpmaint(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2);
static int aurpkg_cmplic(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2);
static int aurpkg_cmpvotes(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2);
static int aurpkg_cmpood(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2);
static int aurpkg_cmplastmod(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2);
static int aurpkg_cmpfirstsub(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2);
static int aurpkg_cmpname(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2);
static int aurpkg_cmp(const void*, const void*);
static struct aurpkg_t *aurpkg_dup(const struct aurpkg_t*);
static void aurpkg_free(void*);
static void aurpkg_free_inner(struct aurpkg_t*);
static int globcompare(const void *a, const void *b);
static const char *category_id_to_string(size_t id);
static CURL *curl_init_easy_handle(CURL*);
static char *curl_get_url_as_buffer(CURL*, const char*);
static size_t curl_write_response(void*, size_t, size_t, void*);
static int cwr_asprintf(char**, const char*, ...) __attribute__((format(printf,2,3)));
static int cwr_fprintf(FILE*, loglevel_t, const char*, ...) __attribute__((format(printf,3,4)));
static int cwr_printf(loglevel_t, const char*, ...) __attribute__((format(printf,2,3)));
static int cwr_vfprintf(FILE*, loglevel_t, const char*, va_list) __attribute__((format(printf,3,0)));
static void *download(CURL *curl, void*);
static alpm_list_t *filter_results(alpm_list_t*);
static char *get_file_as_buffer(const char*);
static int getcols(void);
static int get_config_path(char *config_path, size_t pathlen);
static void indentprint(const char*, int);
static int json_end_map(void*);
static int json_integer(void *ctx, long long);
static int json_map_key(void*, const unsigned char*, size_t);
static int json_start_map(void*);
static int json_string(void*, const unsigned char*, size_t);
static int keycmp(const void *v1, const void *v2);
static alpm_list_t *load_targets_from_files(alpm_list_t *files);
static void openssl_crypto_cleanup(void);
static void openssl_crypto_init(void);
static unsigned long openssl_thread_id(void) __attribute__ ((const));
static void openssl_thread_cb(int, int, const char*, int);
static alpm_list_t *parse_bash_array(alpm_list_t*, char*, pkgdetail_t);
static int parse_configfile(void);
static int parse_options(int, char*[]);
static int parse_keyname(char*);
static int pkg_is_binary(const char *pkg);
static void pkgbuild_get_extinfo(char*, alpm_list_t**[]);
static int print_escaped(const char*);
static void print_extinfo_list(alpm_list_t*, const char*, const char*, int);
static void print_pkg_formatted(struct aurpkg_t*);
static void print_pkg_info(struct aurpkg_t*);
static void print_pkg_search(struct aurpkg_t*);
static void print_results(alpm_list_t*, void (*)(struct aurpkg_t*));
static int read_targets_from_file(FILE *in, alpm_list_t **targets);
static int resolve_dependencies(CURL*, const char*, const char*);
static int set_working_dir(void);
static int strings_init(void);
static int string_to_key(const unsigned char *key, size_t len);
static size_t strtrim(char*);
static void *task_download(CURL*, void*);
static void *task_query(CURL*, void*);
static void *task_update(CURL*, void*);
static void *thread_pool(void*);
static char *url_escape(char*, int, const char*);
static void usage(void);
static void version(void);
static size_t yajl_parse_stream(void*, size_t, size_t, void*);

/* runtime configuration */
static struct {
	char *dlpath;
	const char *delim;
	const char *format;

	operation_t opmask;
	loglevel_t logmask;

	short color;
	short ignoreood;
	short sortorder;
	int extinfo:1;
	int force:1;
	int getdeps:1;
	int quiet:1;
	int skiprepos:1;
	int frompkgbuild:1;
	int maxthreads;
	long timeout;

	int (*sort_fn) (const struct aurpkg_t*, const struct aurpkg_t*);

	alpm_list_t *targets;
	struct {
	  alpm_list_t *pkgs;
	  alpm_list_t *repos;
	} ignore;
} cfg;

/* globals */
static alpm_handle_t *pmhandle;
static alpm_db_t *db_local;
static alpm_list_t *workq;
static struct openssl_mutex_t openssl_lock;
static pthread_mutex_t listlock = PTHREAD_MUTEX_INITIALIZER;

static const int kUnset = -1;
static const int kThreadDefault = 10;
static const int kInfoIndent = 17;
static const int kSearchIndent = 4;
static const int kRegexOpts = REG_ICASE|REG_EXTENDED|REG_NOSUB|REG_NEWLINE;
static const long kTimeoutDefault = 10;
static const char kListDelim[] = "  ";
static const char kCowerUserAgent[] = "cower/" COWER_VERSION;
static const char kRegexChars[] = "^.+*?$[](){}|\\";

static yajl_callbacks callbacks = {
	NULL,             /* null */
	NULL,             /* boolean */
	json_integer,     /* integer */
	NULL,             /* double */
	NULL,             /* number */
	json_string,      /* string */
	json_start_map,   /* start_map */
	json_map_key,     /* map_key */
	json_end_map,     /* end_map */
	NULL,             /* start_array */
	NULL              /* end_array */
};

static char const *digits = "0123456789";
static char const *printf_flags = "'-+ #0I";

static const char *aur_cat[] = { NULL, "None", "daemons", "devel", "editors",
                                "emulators", "games", "gnome", "i18n", "kde", "lib",
                                "modules", "multimedia", "network", "office",
                                "science", "system", "x11", "xfce", "kernels", "fonts" };

static const struct key_t json_keys[] = {
	{ KEY_CATEGORY, "CategoryID" },
	{ KEY_DESCRIPTION, "Description" },
	{ KEY_FIRSTSUB, "FirstSubmitted" },
	{ KEY_ID, "ID" },
	{ KEY_LASTMOD, "LastModified" },
	{ KEY_LICENSE, "License" },
	{ KEY_MAINTAINER, "Maintainer" },
	{ KEY_NAME, "Name" },
	{ KEY_VOTES, "NumVotes" },
	{ KEY_OOD, "OutOfDate" },
	{ KEY_URL, "URL" },
	{ KEY_URLPATH, "URLPath" },
	{ KEY_VERSION, "Version" },
	{ KEY_QUERY_RESULTCOUNT, "resultcount" },
	{ KEY_QUERY_RESULTS, "results" }
};

static struct strings_t colstr = {
	.error = "error:",
	.warn = "warning:",
	.info = "::",
	.pkg = "",
	.repo = "",
	.url = "",
	.ood = "",
	.utd = "",
	.nc = ""
};

int streq(const char *s1, const char *s2)
{
	return strcmp(s1, s2) == 0;
}

int startswith(const char *s1, const char *s2)
{
	return strncmp(s1, s2, strlen(s2)) == 0;
}

alpm_handle_t *alpm_init(void)
{
	FILE *fp;
	char line[PATH_MAX];
	char *ptr, *section = NULL;
	enum _alpm_errno_t err;

	cwr_printf(LOG_DEBUG, "initializing alpm\n");
	pmhandle = alpm_initialize(PACMAN_ROOT, PACMAN_DBPATH, &err);
	if(!pmhandle) {
		fprintf(stderr, "failed to initialize alpm: %s\n", alpm_strerror(err));
		return NULL;
	}

	fp = fopen(PACMAN_CONFIG, "r");
	if(!fp) {
		return pmhandle;
	}

	while(fgets(line, PATH_MAX, fp)) {
		size_t linelen;

		if((ptr = strchr(line, '#'))) {
			*ptr = '\0';
		}
		if(!(linelen = strtrim(line))) {
			continue;
		}

		if(line[0] == '[' && line[linelen - 1] == ']') {
			free(section);
			section = strndup(&line[1], linelen - 2);

			if(!streq(section, "options")) {
				if(!cfg.skiprepos && !alpm_list_find_str(cfg.ignore.repos, section)) {
					alpm_register_syncdb(pmhandle, section, 0);
					cwr_printf(LOG_DEBUG, "registering alpm db: %s\n", section);
				}
			}
		} else {
			char *key, *token;

			key = ptr = line;
			strsep(&ptr, "=");
			strtrim(key);
			strtrim(ptr);
			if(streq(key, "IgnorePkg")) {
				for(token = strtok(ptr, "\t\n "); token; token = strtok(NULL, "\t\n ")) {
					cwr_printf(LOG_DEBUG, "ignoring package: %s\n", token);
					cfg.ignore.pkgs = alpm_list_add(cfg.ignore.pkgs, strdup(token));
				}
			}
		}
	}

	db_local = alpm_get_localdb(pmhandle);

	free(section);
	fclose(fp);

	return pmhandle;
}

alpm_list_t *alpm_find_foreign_pkgs(void)
{
	const alpm_list_t *i;
	alpm_list_t *ret = NULL;

	for(i = alpm_db_get_pkgcache(db_local); i; i = alpm_list_next(i)) {
		alpm_pkg_t *pkg = i->data;

		if(alpm_pkg_is_foreign(pkg)) {
			ret = alpm_list_add(ret, strdup(alpm_pkg_get_name(pkg)));
		}
	}

	return ret;
}

int alpm_pkg_is_foreign(alpm_pkg_t *pkg)
{
	const alpm_list_t *i;
	const char *pkgname;

	pkgname = alpm_pkg_get_name(pkg);

	for(i = alpm_get_syncdbs(pmhandle); i; i = alpm_list_next(i)) {
		if(alpm_db_get_pkg(i->data, pkgname)) {
			return 0;
		}
	}

	return 1;
}

const char *alpm_provides_pkg(const char *pkgname)
{
	const alpm_list_t *i;
	const char *dbname = NULL;
	static pthread_mutex_t alpmlock = PTHREAD_MUTEX_INITIALIZER;

	pthread_mutex_lock(&alpmlock);
	for(i = alpm_get_syncdbs(pmhandle); i; i = alpm_list_next(i)) {
		alpm_db_t *db = i->data;
		if(alpm_find_satisfier(alpm_db_get_pkgcache(db), pkgname)) {
			dbname = alpm_db_get_name(db);
			break;
		}
	}
	pthread_mutex_unlock(&alpmlock);

	return dbname;
}

int archive_extract_file(const struct response_t *file, char **subdir)
{
	struct archive *archive;
	struct archive_entry *entry;
	const int archive_flags = ARCHIVE_EXTRACT_PERM | ARCHIVE_EXTRACT_TIME;
	int want_subdir = subdir != NULL, ok, ret = 0;

	archive = archive_read_new();
	archive_read_support_filter_all(archive);
	archive_read_support_format_all(archive);

	want_subdir = (subdir != NULL);

	ret = archive_read_open_memory(archive, file->data, file->size);
	if(ret == ARCHIVE_OK) {
		while(archive_read_next_header(archive, &entry) == ARCHIVE_OK) {
			const char *entryname = archive_entry_pathname(entry);

			if(want_subdir) {
				size_t entrylen = strlen(entryname);
				if(streq(&entryname[entrylen - sizeof("PKGBUILD")], "/PKGBUILD")) {
					*subdir = strndup(entryname, entrylen - sizeof("PKGBUILD"));
					cwr_printf(LOG_DEBUG, "found subdir: %s\n", *subdir);
					want_subdir = 0;
				}
			}

			cwr_printf(LOG_DEBUG, "extracting file: %s\n", entryname);

			ok = archive_read_extract(archive, entry, archive_flags);
			/* NOOP ON ARCHIVE_{OK,WARN,RETRY} */
			if(ok == ARCHIVE_FATAL || ok == ARCHIVE_WARN) {
				ret = archive_errno(archive);
				break;
			} else if (ok == ARCHIVE_EOF) {
				ret = 0;
				break;
			}
		}
		archive_read_close(archive);
	}
	archive_read_free(archive);

	if(want_subdir && *subdir == NULL) {
		/* massively broken PKGBUILD without a subdir... */
		*subdir = strdup("");
	}

	return ret;
}

int aurpkg_cmp(const void *p1, const void *p2)
{
	const struct aurpkg_t *pkg1 = p1;
	const struct aurpkg_t *pkg2 = p2;

	return cfg.sortorder * (cfg.sort_fn)(pkg1, pkg2);
}

int aurpkg_cmpname(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2) {
	return strcmp(pkg1->name, pkg2->name);
}

int aurpkg_cmpver(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2) {
	return alpm_pkg_vercmp(pkg1->ver, pkg2->ver);
}

int aurpkg_cmpmaint(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2) {
	return strcmp(pkg1->maint, pkg2->maint);
}

int aurpkg_cmplic(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2) {
	return strcmp(pkg1->lic, pkg2->lic);
}

int aurpkg_cmpvotes(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2) {
	return pkg1->votes - pkg2->votes;
}

int aurpkg_cmpood(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2) {
	return pkg1->ood - pkg2->ood;
}

int aurpkg_cmplastmod(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2) {
	return difftime(pkg1->lastmod, pkg2->lastmod);
}

int aurpkg_cmpfirstsub(const struct aurpkg_t *pkg1, const struct aurpkg_t *pkg2) {
	return difftime(pkg1->firstsub, pkg2->firstsub);
}

struct aurpkg_t *aurpkg_dup(const struct aurpkg_t *pkg)
{
	struct aurpkg_t *newpkg;

	newpkg = malloc(sizeof(struct aurpkg_t));
	return newpkg ? memcpy(newpkg, pkg, sizeof(struct aurpkg_t)) : NULL;
}

void aurpkg_free(void *pkg)
{
	aurpkg_free_inner(pkg);
	free(pkg);
}

int globcompare(const void *a, const void *b)
{
	return fnmatch(a, b, 0);
}

void aurpkg_free_inner(struct aurpkg_t *pkg)
{
	if(!pkg) {
		return;
	}

	/* free allocated string fields */
	free(pkg->name);
	free(pkg->maint);
	free(pkg->ver);
	free(pkg->urlpath);
	free(pkg->desc);
	free(pkg->url);
	free(pkg->lic);

	/* free extended list info */
	FREELIST(pkg->depends);
	FREELIST(pkg->makedepends);
	FREELIST(pkg->optdepends);
	FREELIST(pkg->provides);
	FREELIST(pkg->conflicts);
	FREELIST(pkg->replaces);

	memset(pkg, 0, sizeof(struct aurpkg_t));
}

const char *category_id_to_string(size_t id)
{
	if(id >= (sizeof(aur_cat)/sizeof(aur_cat[0] + 1))) {
		return "Unknown";
	} else {
		return aur_cat[id];
	}
}

int cwr_asprintf(char **string, const char *format, ...)
{
	int ret = 0;
	va_list args;

	va_start(args, format);
	ret = vasprintf(string, format, args);
	va_end(args);

	if(ret == -1) {
		cwr_fprintf(stderr, LOG_ERROR, "failed to allocate string\n");
	}

	return ret;
}

int cwr_fprintf(FILE *stream, loglevel_t level, const char *format, ...)
{
	int ret;
	va_list args;

	va_start(args, format);
	ret = cwr_vfprintf(stream, level, format, args);
	va_end(args);

	return ret;
}

int cwr_printf(loglevel_t level, const char *format, ...)
{
	int ret;
	va_list args;

	va_start(args, format);
	ret = cwr_vfprintf(stdout, level, format, args);
	va_end(args);

	return ret;
}

int cwr_vfprintf(FILE *stream, loglevel_t level, const char *format, va_list args)
{
	const char *prefix;
	char bufout[128];

	if(!(cfg.logmask & level)) {
		return 0;
	}

	switch(level) {
		case LOG_VERBOSE:
		case LOG_INFO:
			prefix = colstr.info;
			break;
		case LOG_ERROR:
			prefix = colstr.error;
			break;
		case LOG_WARN:
			prefix = colstr.warn;
			break;
		case LOG_DEBUG:
			prefix = "debug:";
			break;
		default:
			prefix = "";
			break;
	}

	/* f.l.w.: 128 should be big enough... */
	snprintf(bufout, 128, "%s %s", prefix, format);

	return vfprintf(stream, bufout, args);
}

CURL *curl_init_easy_handle(CURL *handle)
{
	if(!handle) {
		return NULL;
	}

	curl_easy_reset(handle);
	curl_easy_setopt(handle, CURLOPT_USERAGENT, kCowerUserAgent);
	curl_easy_setopt(handle, CURLOPT_ENCODING, "deflate, gzip");
	curl_easy_setopt(handle, CURLOPT_CONNECTTIMEOUT, cfg.timeout);
	curl_easy_setopt(handle, CURLOPT_FOLLOWLOCATION, 1L);

	/* This is required of multi-threaded apps using timeouts. See
	 * curl_easy_setopt(3) */
	if(cfg.timeout > 0L) {
		curl_easy_setopt(handle, CURLOPT_NOSIGNAL, 1L);
	}

	return handle;
}

char *curl_get_url_as_buffer(CURL *curl, const char *url)
{
	long httpcode;
	struct response_t response = { NULL, 0 };
	CURLcode curlstat;

	curl = curl_init_easy_handle(curl);
	curl_easy_setopt(curl, CURLOPT_URL, url);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_write_response);
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);

	cwr_printf(LOG_DEBUG, "get_url_as_buffer: curl_easy_perform %s\n", url);
	curlstat = curl_easy_perform(curl);
	if(curlstat != CURLE_OK) {
		cwr_fprintf(stderr, LOG_ERROR, "%s: %s\n", url, curl_easy_strerror(curlstat));
		goto finish;
	}

	curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpcode);
	cwr_printf(LOG_DEBUG, "get_url_as_buffer: %s: server responded with %ld\n", url, httpcode);
	if(httpcode >= 400) {
		cwr_fprintf(stderr, LOG_ERROR, "%s: server responded with HTTP %ld\n",
				url, httpcode);
	}

finish:
	return response.data;
}

size_t curl_write_response(void *ptr, size_t size, size_t nmemb, void *stream)
{
	void *newdata;
	size_t realsize = size * nmemb;
	struct response_t *mem = stream;

	newdata = realloc(mem->data, mem->size + realsize + 1);
	if(newdata) {
		mem->data = newdata;
		memcpy(&(mem->data[mem->size]), ptr, realsize);
		mem->size += realsize;
		mem->data[mem->size] = '\0';
	} else {
		cwr_fprintf(stderr, LOG_ERROR, "failed to reallocate %zd bytes\n",
				mem->size + realsize + 1);
		return 0;
	}

	return realsize;
}

void *download(CURL *curl, void *arg)
{
	alpm_list_t *queryresult = NULL;
	struct aurpkg_t *result;
	CURLcode curlstat;
	char *url, *escaped, *subdir = NULL;
	int ret;
	long httpcode;
	struct response_t response = { 0, 0 };

	curl = curl_init_easy_handle(curl);

	queryresult = task_query(curl, arg);
	if(!queryresult) {
		cwr_fprintf(stderr, LOG_BRIEF, BRIEF_ERR "\t%s\t", (const char*)arg);
		cwr_fprintf(stderr, LOG_ERROR, "no results found for %s\n", (const char*)arg);
		return NULL;
	}

	if(access(arg, F_OK) == 0 && !cfg.force) {
		cwr_fprintf(stderr, LOG_BRIEF, BRIEF_ERR "\t%s\t", (const char*)arg);
		cwr_fprintf(stderr, LOG_ERROR, "`%s/%s' already exists. Use -f to overwrite.\n",
				cfg.dlpath, (const char*)arg);
		alpm_list_free_inner(queryresult, aurpkg_free);
		alpm_list_free(queryresult);
		return NULL;
	}

	curl_easy_setopt(curl, CURLOPT_ENCODING, "identity"); /* disable compression */
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_write_response);

	result = queryresult->data;
	escaped = url_escape(result->urlpath, 0, "/");
	cwr_asprintf(&url, AUR_BASE_URL "%s", escaped);
	curl_easy_setopt(curl, CURLOPT_URL, url);
	free(escaped);

	cwr_printf(LOG_DEBUG, "[%s]: curl_easy_perform %s\n", (const char*)arg, url);
	curlstat = curl_easy_perform(curl);

	if(curlstat != CURLE_OK) {
		cwr_fprintf(stderr, LOG_BRIEF, BRIEF_ERR "\t%s\t", (const char*)arg);
		cwr_fprintf(stderr, LOG_ERROR, "[%s]: %s\n", (const char*)arg, curl_easy_strerror(curlstat));
		goto finish;
	}

	curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpcode);
	cwr_printf(LOG_DEBUG, "[%s]: server responded with %ld\n", (const char *)arg, httpcode);

	switch(httpcode) {
		case 200:
			break;
		default:
			cwr_fprintf(stderr, LOG_BRIEF, BRIEF_ERR "\t%s\t", (const char*)arg);
			cwr_fprintf(stderr, LOG_ERROR, "[%s]: server responded with HTTP %ld\n",
					(const char*)arg, httpcode);
			goto finish;
	}

	ret = archive_extract_file(&response, &subdir);
	if(ret != 0) {
		cwr_fprintf(stderr, LOG_BRIEF, BRIEF_ERR "\t%s\t", (const char*)arg);
		cwr_fprintf(stderr, LOG_ERROR, "[%s]: failed to extract tarball: %s\n",
				(const char*)arg, strerror(ret));
		goto finish;
	}

	cwr_printf(LOG_BRIEF, BRIEF_OK "\t%s\t", result->name);
	cwr_printf(LOG_INFO, "%s%s%s downloaded to %s\n",
			colstr.pkg, result->name, colstr.nc, cfg.dlpath);

	if(cfg.getdeps) {
		resolve_dependencies(curl, arg, subdir);
	}

finish:
	free(url);
	free(response.data);
	free(subdir);

	return queryresult;
}

alpm_list_t *filter_results(alpm_list_t *list)
{
	const alpm_list_t *i, *j;
	alpm_list_t *filterlist = NULL;

	if(!(cfg.opmask & OP_SEARCH)) {
		return list;
	}

	for(i = cfg.targets; i; i = alpm_list_next(i)) {
		regex_t regex;
		const char *targ = i->data;
		filterlist = NULL;

		if(regcomp(&regex, targ, kRegexOpts) == 0) {
			for(j = list; j; j = alpm_list_next(j)) {
				struct aurpkg_t *pkg = j->data;
				const char *name = pkg->name;
				const char *desc = pkg->desc;

				if(regexec(&regex, name, 0, 0, 0) != REG_NOMATCH ||
						regexec(&regex, desc, 0, 0, 0) != REG_NOMATCH) {
					filterlist = alpm_list_add(filterlist, pkg);
				} else {
					aurpkg_free(pkg);
				}
			}
			regfree(&regex);
		}

		/* switcheroo */
		alpm_list_free(list);
		list = filterlist;
	}

	return alpm_list_msort(filterlist, alpm_list_count(filterlist), aurpkg_cmp);
}

int getcols(void)
{
	int termwidth = -1;
	const int default_tty = 80;
	const int default_notty = 0;

	if(!isatty(fileno(stdout))) {
		return default_notty;
	}

#ifdef TIOCGSIZE
	struct ttysize win;
	if(ioctl(1, TIOCGSIZE, &win) == 0) {
		termwidth = win.ts_cols;
	}
#elif defined(TIOCGWINSZ)
	struct winsize win;
	if(ioctl(1, TIOCGWINSZ, &win) == 0) {
		termwidth = win.ws_col;
	}
#endif
	return termwidth <= 0 ? default_tty : termwidth;
}

char *get_file_as_buffer(const char *path)
{
	FILE *fp;
	char *buf;
	long fsize, nread;

	fp = fopen(path, "r");
	if(!fp) {
		cwr_fprintf(stderr, LOG_ERROR, "error: failed to open %s: %s\n",
				path, strerror(errno));
		return NULL;
	}

	fseek(fp, 0L, SEEK_END);
	fsize = ftell(fp);
	fseek(fp, 0L, SEEK_SET);

	buf = calloc(1, (size_t)fsize + 1);

	nread = fread(buf, 1, fsize, fp);
	fclose(fp);

	if(nread < fsize) {
		cwr_fprintf(stderr, LOG_ERROR, "Failed to read full PKGBUILD\n");
		return NULL;
	}

	return buf;
}

int get_config_path(char *config_path, size_t pathlen)
{
	char *var;
	struct passwd *pwd;

	var = getenv("XDG_CONFIG_HOME");
	if(var != NULL) {
		snprintf(config_path, pathlen, "%s/cower/config", var);
		return 0;
	}

	var = getenv("HOME");
	if(var != NULL) {
		snprintf(config_path, pathlen, "%s/.config/cower/config", var);
		return 0;
	}

	pwd = getpwuid(getuid());
	if(pwd != NULL && pwd->pw_dir != NULL) {
		snprintf(config_path, pathlen, "%s/.config/cower/config", pwd->pw_dir);
		return 0;
	}

	return 1;
}

void indentprint(const char *str, int indent)
{
	wchar_t *wcstr;
	const wchar_t *p;
	int len, cidx, cols;

	if(!str) {
		return;
	}

	cols = getcols();

	/* if we're not a tty, print without indenting */
	if(cols == 0) {
		fputs(str, stdout);
		return;
	}

	len = strlen(str) + 1;
	wcstr = calloc(len, sizeof(wchar_t));
	len = mbstowcs(wcstr, str, len);
	p = wcstr;
	cidx = indent;

	if(!p || !len) {
		return;
	}

	while(*p) {
		if(*p == L' ') {
			const wchar_t *q, *next;
			p++;
			if(!p || *p == L' ') {
				continue;
			}
			next = wcschr(p, L' ');
			if(!next) {
				next = p + wcslen(p);
			}

			/* len captures # cols */
			len = 0;
			q = p;

			while(q < next) {
				len += wcwidth(*q++);
			}

			if(len > (cols - cidx - 1)) {
				/* wrap to a newline and reindent */
				printf("\n%-*s", indent, "");
				cidx = indent;
			} else {
				fputc(' ', stdout);
				cidx++;
			}
			continue;
		}
#ifdef __clang__
		printf("%lc", *p);
#else /* assume GCC */
		printf("%lc", (wint_t)*p);
#endif
		cidx += wcwidth(*p);
		p++;
	}
	free(wcstr);
}

int json_end_map(void *ctx)
{
	struct yajl_parser_t *p = ctx;

	p->json_depth--;
	if(p->json_depth > 0) {
		if(!(p->aurpkg->ood && cfg.ignoreood)) {
			p->pkglist = alpm_list_add_sorted(p->pkglist, aurpkg_dup(p->aurpkg), aurpkg_cmp);
		} else {
			aurpkg_free_inner(p->aurpkg);
		}
	}

	return 1;
}

int json_integer(void *ctx, long long val)
{
	struct yajl_parser_t *p = ctx;

	switch (p->key) {
	case KEY_ID:
		p->aurpkg->id = (int)val;
		break;
	case KEY_CATEGORY:
		p->aurpkg->cat = (int)val;
		break;
	case KEY_VOTES:
		p->aurpkg->votes = (int)val;
		break;
	case KEY_OOD:
		p->aurpkg->ood = (int)val;
		break;
	case KEY_FIRSTSUB:
		p->aurpkg->firstsub = (time_t)val;
		break;
	case KEY_LASTMOD:
		p->aurpkg->lastmod = (time_t)val;
		break;
	case KEY_QUERY_RESULTCOUNT:
		p->resultcount = (int)val;
		break;
	default:
		/* ignore other keys */
		break;
	}

	return 1;
}

int json_map_key(void *ctx, const unsigned char *data, size_t size)
{
	struct yajl_parser_t *p = ctx;

	p->key = string_to_key(data, size);

	return 1;
}

int json_start_map(void *ctx)
{
	struct yajl_parser_t *p = ctx;

	p->json_depth++;
	if(p->json_depth > 1) {
		memset(p->aurpkg, 0, sizeof(struct aurpkg_t));
	}

	return 1;
}

int json_string(void *ctx, const unsigned char *data, size_t size)
{
	struct yajl_parser_t *p = ctx;
	char **key = NULL;

	switch(p->key) {
	case KEY_QUERY_RESULTS:
		/* usually the AUR returns this as an array. when it shows
		 * up as a string, it means we have an error. gross. */
		p->error = strndup((const char*)data, size);
		return 0;
	case KEY_NAME:
		key = &p->aurpkg->name;
		break;
	case KEY_MAINTAINER:
		key = &p->aurpkg->maint;
		break;
	case KEY_VERSION:
		key = &p->aurpkg->ver;
		break;
	case KEY_DESCRIPTION:
		key = &p->aurpkg->desc;
		break;
	case KEY_URL:
		key = &p->aurpkg->url;
		break;
	case KEY_URLPATH:
		key = &p->aurpkg->urlpath;
		break;
	case KEY_LICENSE:
		key = &p->aurpkg->lic;
		break;
	default:
		/* ignored other fields */
		return 1;
	}

	*key = strndup((const char*)data, size);
	if(*key == NULL) {
		cwr_fprintf(stderr, LOG_ERROR, "failed to allocate string: %s\n",
				strerror(errno));
	}

	return 1;
}

int keycmp(const void *v1, const void *v2)
{
	const struct key_t *k1 = v1;
	const struct key_t *k2 = v2;

	return strcmp(k1->name, k2->name);
}

alpm_list_t *load_targets_from_files(alpm_list_t *files)
{
	alpm_list_t *i, *targets = NULL, *results = NULL;

	for(i = files; i; i = i->next) {
		alpm_list_t *depends = NULL;
		char *pkgbuild = get_file_as_buffer(i->data);

		alpm_list_t **pkg_details[PKGDETAIL_MAX] = {
			&depends, &depends, NULL, NULL, NULL
		};

		pkgbuild_get_extinfo(pkgbuild, pkg_details);
		free(pkgbuild);

		results = alpm_list_join(results, depends);
	}

	/* sanitize and dedupe */
	for(i = results; i; i = i->next) {
		char *sanitized = strdup(i->data);

		sanitized[strcspn(sanitized, "<>=")] = '\0';
		if(!alpm_list_find_str(targets, sanitized)) {
			targets = alpm_list_add(targets, sanitized);
		}
	}

	return targets;
}

void openssl_crypto_cleanup(void)
{
	int i;

	CRYPTO_set_locking_callback(NULL);

	for(i = 0; i < CRYPTO_num_locks(); i++) {
		pthread_mutex_destroy(&(openssl_lock.lock[i]));
	}

	OPENSSL_free(openssl_lock.lock);
	OPENSSL_free(openssl_lock.lock_count);
}

void openssl_crypto_init(void)
{
	int i;

	openssl_lock.lock = OPENSSL_malloc(CRYPTO_num_locks() * sizeof(pthread_mutex_t));
	openssl_lock.lock_count = OPENSSL_malloc(CRYPTO_num_locks() * sizeof(long));
	for(i = 0; i < CRYPTO_num_locks(); i++) {
		openssl_lock.lock_count[i] = 0;
		pthread_mutex_init(&(openssl_lock.lock[i]), NULL);
	}

	CRYPTO_set_id_callback(openssl_thread_id);
	CRYPTO_set_locking_callback(openssl_thread_cb);
}

void openssl_thread_cb(int mode, int type, const char UNUSED *file,
		int UNUSED line)
{
	if(mode & CRYPTO_LOCK) {
		pthread_mutex_lock(&(openssl_lock.lock[type]));
		openssl_lock.lock_count[type]++;
	} else {
		pthread_mutex_unlock(&(openssl_lock.lock[type]));
		openssl_lock.lock_count[type]--;
	}
}

unsigned long openssl_thread_id(void)
{
	return pthread_self();
}

alpm_list_t *parse_bash_array(alpm_list_t *deplist, char *array, pkgdetail_t type)
{
	char *ptr, *token, *saveptr;

	if(!array) {
		return NULL;
	}

	if(type == PKGDETAIL_OPTDEPENDS) {
		const char *arrayend = rawmemchr(array, '\0');
		for(token = array; token <= arrayend; token++) {
			if(*token == '\'' || *token == '\"') {
				token++;
				ptr = memchr(token, *(token - 1), arrayend - token);
				*ptr = '\0';
			} else if(isalpha(*token)) {
				ptr = token;
				while(!isspace(*++ptr));
				*(ptr - 1) = '\0';
			} else {
				continue;
			}

			strtrim(token);
			cwr_printf(LOG_DEBUG, "adding depend: %s\n", token);
			deplist = alpm_list_add(deplist, strdup(token));

			token = ptr;
		}
		return deplist;
	}

	for(token = strtok_r(array, " \t\n", &saveptr); token;
			token = strtok_r(NULL, " \t\n", &saveptr)) {
		/* found an embedded comment. skip to the next line */
		if(*token == '#') {
			strtok_r(NULL, "\n", &saveptr);
			continue;
		}

		/* unquote the element */
		if(*token == '\'' || *token == '\"') {
			ptr = strrchr(token + 1, *token);
			if(ptr) {
				token++;
				*ptr = '\0';
			}
		}

		/* some people feel compelled to do insane things in PKGBUILDs. these people suck */
		if(!*token || strlen(token) < 2 || *token == '$') {
			continue;
		}

		cwr_printf(LOG_DEBUG, "adding depend: %s\n", token);
		if(!alpm_list_find_str(deplist, token)) {
			deplist = alpm_list_add(deplist, strdup(token));
		}
	}

	return deplist;
}

int parse_configfile(void)
{
	char line[BUFSIZ], config_path[PATH_MAX];
	int ret = 0;
	FILE *fp;

	if(get_config_path(config_path, sizeof(config_path)) != 0) {
		return 0;
	}

	fp = fopen(config_path, "r");
	if(!fp) {
		cwr_printf(LOG_DEBUG, "config file not found. skipping parsing\n");
		return 0; /* not an error, just nothing to do here */
	}

	while(fgets(line, sizeof(line), fp)) {
		char *key, *val;
		size_t linelen;

		linelen = strtrim(line);
		if(!linelen || line[0] == '#') {
			continue;
		}

		if((val = strchr(line, '#'))) {
			*val = '\0';
		}

		key = val = line;
		strsep(&val, "=");
		strtrim(key);
		strtrim(val);

		if(val && !*val) {
			val = NULL;
		}

		cwr_printf(LOG_DEBUG, "found config option: %s => %s\n", key, val);

		/* colors are not initialized in this section, so usage of cwr_printf
		 * functions is verboten unless we're using loglevel_t LOG_DEBUG */
		if(streq(key, "IgnoreRepo")) {
			for(key = strtok(val, " "); key; key = strtok(NULL, " ")) {
				cwr_printf(LOG_DEBUG, "ignoring repo: %s\n", key);
				cfg.ignore.repos = alpm_list_add(cfg.ignore.repos, strdup(key));
			}
		} else if(streq(key, "IgnorePkg")) {
			for(key = strtok(val, " "); key; key = strtok(NULL, " ")) {
				cwr_printf(LOG_DEBUG, "ignoring package: %s\n", key);
				cfg.ignore.pkgs = alpm_list_add(cfg.ignore.pkgs, strdup(key));
			}
		} else if(streq(key, "IgnoreOOD")) {
			if(cfg.ignoreood == kUnset) {
				cfg.ignoreood = 1;
			}
		} else if(streq(key, "TargetDir")) {
			if(val && !cfg.dlpath) {
				wordexp_t p;
				if(wordexp(val, &p, 0) == 0) {
					if(p.we_wordc == 1) {
						cfg.dlpath = strdup(p.we_wordv[0]);
					}
					wordfree(&p);
					/* error on relative paths */
					if(*cfg.dlpath != '/') {
						fprintf(stderr, "error: TargetDir cannot be a relative path\n");
						ret = 1;
					}
				} else {
					fprintf(stderr, "error: failed to resolve option to TargetDir\n");
					ret = 1;
				}
			}
		} else if(streq(key, "MaxThreads")) {
			if(val && cfg.maxthreads == kUnset) {
				cfg.maxthreads = strtol(val, &key, 10);
				if(*key != '\0' || cfg.maxthreads <= 0) {
					fprintf(stderr, "error: invalid option to MaxThreads: %s\n", val);
					ret = 1;
				}
			}
		} else if(streq(key, "ConnectTimeout")) {
			if(val && cfg.timeout == kUnset) {
				cfg.timeout = strtol(val, &key, 10);
				if(*key != '\0' || cfg.timeout < 0) {
					fprintf(stderr, "error: invalid option to ConnectTimeout: %s\n", val);
					ret = 1;
				}
			}
		} else if(streq(key, "Color")) {
			if(cfg.color == kUnset) {
				if(!val || streq(val, "auto")) {
					if(isatty(fileno(stdout))) {
						cfg.color = 1;
					} else {
						cfg.color = 0;
					}
				} else if(streq(val, "always")) {
					cfg.color = 1;
				} else if(streq(val, "never")) {
					cfg.color = 0;
				} else {
					fprintf(stderr, "error: invalid option to Color\n");
					return 1;
				}
			}
		} else {
			fprintf(stderr, "ignoring unknown option: %s\n", key);
		}
		if(ret > 0) {
			goto finish;
		}
	}

finish:
	fclose(fp);
	return ret;
}

int parse_options(int argc, char *argv[])
{
	int opt, option_index = 0;

	static const struct option opts[] = {
		/* operations */
		{"download",      no_argument,        0, 'd'},
		{"info",          no_argument,        0, 'i'},
		{"msearch",       no_argument,        0, 'm'},
		{"search",        no_argument,        0, 's'},
		{"update",        no_argument,        0, 'u'},

		/* options */
		{"brief",         no_argument,        0, 'b'},
		{"color",         optional_argument,  0, 'c'},
		{"debug",         no_argument,        0, OP_DEBUG},
		{"force",         no_argument,        0, 'f'},
		{"format",        required_argument,  0, OP_FORMAT},
		{"sort",          required_argument,  0, OP_SORT},
		{"rsort",         required_argument,  0, OP_RSORT},
		{"from-pkgbuild", no_argument,        0, 'p'},
		{"help",          no_argument,        0, 'h'},
		{"ignore",        required_argument,  0, OP_IGNOREPKG},
		{"ignore-ood",    no_argument,        0, 'o'},
		{"no-ignore-ood", no_argument,        0, OP_NOIGNOREOOD},
		{"ignorerepo",    optional_argument,  0, OP_IGNOREREPO},
		{"listdelim",     required_argument,  0, OP_LISTDELIM},
		{"quiet",         no_argument,        0, 'q'},
		{"target",        required_argument,  0, 't'},
		{"threads",       required_argument,  0, OP_THREADS},
		{"timeout",       required_argument,  0, OP_TIMEOUT},
		{"verbose",       no_argument,        0, 'v'},
		{"version",       no_argument,        0, 'V'},
		{0, 0, 0, 0}
	};

	while((opt = getopt_long(argc, argv, "bc::dfhimopqst:uvV", opts, &option_index)) != -1) {
		char *token;

		switch(opt) {
			/* operations */
			case 's':
				cfg.opmask |= OP_SEARCH;
				break;
			case 'u':
				cfg.opmask |= OP_UPDATE;
				break;
			case 'i':
				if(!(cfg.opmask & OP_INFO)) {
					cfg.opmask |= OP_INFO;
				} else {
					cfg.extinfo |= 1;
				}
				break;
			case 'd':
				if(!(cfg.opmask & OP_DOWNLOAD)) {
					cfg.opmask |= OP_DOWNLOAD;
				} else {
					cfg.getdeps |= 1;
				}
				break;
			case 'm':
				cfg.opmask |= OP_MSEARCH;
				break;

			/* options */
			case 'b':
				cfg.logmask |= LOG_BRIEF;
				break;
			case 'c':
				if(!optarg || streq(optarg, "auto")) {
					if(isatty(fileno(stdout))) {
						cfg.color = 1;
					} else {
						cfg.color = 0;
					}
				} else if(streq(optarg, "always")) {
					cfg.color = 1;
				} else if(streq(optarg, "never")) {
					cfg.color = 0;
				} else {
					fprintf(stderr, "invalid argument to --color\n");
					return 1;
				}
				break;
			case 'f':
				cfg.force |= 1;
				break;
			case 'h':
				usage();
				exit(0);
			case 'q':
				cfg.quiet |= 1;
				break;
			case 't':
				cfg.dlpath = strdup(optarg);
				break;
			case 'v':
				cfg.logmask |= LOG_VERBOSE;
				break;
			case 'V':
				version();
				exit(0);
			case OP_DEBUG:
				cfg.logmask |= LOG_DEBUG;
				break;
			case OP_FORMAT:
				cfg.format = optarg;
				break;
			case OP_RSORT:
				cfg.sortorder = SORT_REVERSE;
			case OP_SORT:
				if(parse_keyname(optarg)) {
					fprintf(stderr, "error: invalid argument to --%s\n", opts[option_index].name);
					return 1;
				}
				break;
			case 'o':
				cfg.ignoreood = 1;
				break;
			case 'p':
				cfg.frompkgbuild |= 1;
				break;
			case OP_IGNOREPKG:
				for(token = strtok(optarg, ","); token; token = strtok(NULL, ",")) {
					cwr_printf(LOG_DEBUG, "ignoring package: %s\n", token);
					cfg.ignore.pkgs = alpm_list_add(cfg.ignore.pkgs, strdup(token));
				}
				break;
			case OP_IGNOREREPO:
				if(!optarg) {
					cfg.skiprepos |= 1;
				} else {
					for(token = strtok(optarg, ","); token; token = strtok(NULL, ",")) {
						cwr_printf(LOG_DEBUG, "ignoring repos: %s\n", token);
						cfg.ignore.repos = alpm_list_add(cfg.ignore.repos, strdup(token));
					}
				}
				break;
			case OP_NOIGNOREOOD:
				cfg.ignoreood = 0;
				break;
			case OP_LISTDELIM:
				cfg.delim = optarg;
				break;
			case OP_THREADS:
				cfg.maxthreads = strtol(optarg, &token, 10);
				if(*token != '\0' || cfg.maxthreads <= 0) {
					fprintf(stderr, "error: invalid argument to --threads\n");
					return 1;
				}
				break;
			case OP_TIMEOUT:
				cfg.timeout = strtol(optarg, &token, 10);
				if(*token != '\0') {
					fprintf(stderr, "error: invalid argument to --timeout\n");
					return 1;
				}
				break;
			case '?':
			default:
				return 1;
		}
	}

	if(!cfg.opmask) {
		return 3;
	}

#define NOT_EXCL(val) (cfg.opmask & (val) && (cfg.opmask & ~(val)))
	/* check for invalid operation combos */
	if(NOT_EXCL(OP_INFO) || NOT_EXCL(OP_SEARCH) || NOT_EXCL(OP_MSEARCH) ||
			NOT_EXCL(OP_UPDATE|OP_DOWNLOAD)) {
		fprintf(stderr, "error: invalid operation\n");
		return 1;
	}

	while(optind < argc) {
		if(!alpm_list_find_str(cfg.targets, argv[optind])) {
			cwr_printf(LOG_DEBUG, "adding target: %s\n", argv[optind]);
			cfg.targets = alpm_list_add(cfg.targets, strdup(argv[optind]));
		}
		optind++;
	}

	return 0;
}

int parse_keyname(char* keyname)
{
	if(streq("name", keyname)) {
		cfg.sort_fn = aurpkg_cmpname;
		return 0;
	} else if(streq("votes", keyname)) {
		cfg.sort_fn = aurpkg_cmpvotes;
		return 0;
	} else if(streq("version", keyname)) {
		cfg.sort_fn = aurpkg_cmpver;
		return 0;
	} else if(streq("maintainer", keyname)) {
		cfg.sort_fn = aurpkg_cmpmaint;
		return 0;
	} else if(streq("licence", keyname)) {
		cfg.sort_fn = aurpkg_cmplic;
		return 0;
	} else if(streq("votes", keyname)) {
		cfg.sort_fn = aurpkg_cmpvotes;
		return 0;
	} else if(streq("outofdate", keyname)) {
		cfg.sort_fn = aurpkg_cmpood;
		return 0;
	} else if(streq("lastmodified", keyname)) {
		cfg.sort_fn = aurpkg_cmplastmod;
		return 0;
	} else if(streq("firstsubmitted", keyname)) {
		cfg.sort_fn = aurpkg_cmpfirstsub;
		return 0;
	}
	return 1;
}

int pkg_is_binary(const char *pkg)
{
	const char *db = alpm_provides_pkg(pkg);

	if(db) {
		cwr_fprintf(stderr, LOG_BRIEF, BRIEF_WARN "\t%s\t", pkg);
		cwr_fprintf(stderr, LOG_WARN, "%s%s%s is available in %s%s%s\n",
				colstr.pkg, pkg, colstr.nc,
				colstr.repo, db, colstr.nc);
		return 1;
	}

	return 0;
}

void pkgbuild_get_extinfo(char *pkgbuild, alpm_list_t **details[])
{
	char *lineptr;

	for(lineptr = pkgbuild; lineptr; lineptr = strchr(lineptr, '\n')) {
		char *arrayend;
		int depth = 1, type = 0;
		alpm_list_t **deplist;
		size_t linelen;

		linelen = strtrim(++lineptr);
		if(!linelen || *lineptr == '#') {
			continue;
		}

		if(startswith(lineptr, "depends=(")) {
			deplist = details[PKGDETAIL_DEPENDS];
		} else if(startswith(lineptr, "makedepends=(")) {
			deplist = details[PKGDETAIL_MAKEDEPENDS];
		} else if(startswith(lineptr, "optdepends=(")) {
			deplist = details[PKGDETAIL_OPTDEPENDS];
			type = PKGDETAIL_OPTDEPENDS;
		} else if(startswith(lineptr, "provides=(")) {
			deplist = details[PKGDETAIL_PROVIDES];
		} else if(startswith(lineptr, "replaces=(")) {
			deplist = details[PKGDETAIL_REPLACES];
		} else if(startswith(lineptr, "conflicts=(")) {
			deplist = details[PKGDETAIL_CONFLICTS];
		} else {
			continue;
		}

		if(deplist) {
			char *arrayptr = (char*)memchr(lineptr, '(', linelen) + 1;
			for(arrayend = arrayptr; depth; arrayend++) {
				switch(*arrayend) {
					case ')':
						depth--;
						break;
					case '(':
						depth++;
						break;
				}
			}
			*(arrayend - 1) = '\0';
			*deplist = parse_bash_array(*deplist, arrayptr, type);
			lineptr = arrayend;
		}
	}
}

int print_escaped(const char *delim)
{
	const char *f;
	int out = 0;

	for(f = delim; *f != '\0'; f++) {
		if(*f == '\\') {
			switch(*++f) {
				case '\\':
					fputc('\\', stdout);
					break;
				case '"':
					fputc('\"', stdout);
					break;
				case 'a':
					fputc('\a', stdout);
					break;
				case 'b':
					fputc('\b', stdout);
					break;
				case 'e': /* \e is nonstandard */
					fputc('\033', stdout);
					break;
				case 'n':
					fputc('\n', stdout);
					break;
				case 'r':
					fputc('\r', stdout);
					break;
				case 't':
					fputc('\t', stdout);
					break;
				case 'v':
					fputc('\v', stdout);
					break;
				++out;
			}
		} else {
			fputc(*f, stdout);
			++out;
		}
	}

	return(out);
}

void print_extinfo_list(alpm_list_t *list, const char *fieldname, const char *delim, int wrap)
{
	const alpm_list_t *next, *i;
	size_t cols, count = 0;

	if(!list) {
		return;
	}

	cols = wrap ? getcols() : 0;

	if(fieldname) {
		count += printf("%-*s: ", kInfoIndent - 2, fieldname);
	}

	for(i = list; i; i = next) {
		size_t data_len = strlen(i->data);
		next = alpm_list_next(i);
		if(wrap && cols > 0 && count + data_len >= cols) {
			printf("%-*c", kInfoIndent + 1, '\n');
			count = kInfoIndent;
		}
		count += data_len;
		fputs(i->data, stdout);
		if(next) {
			count += print_escaped(delim);
		}
	}
	fputc('\n', stdout);
}

void print_pkg_formatted(struct aurpkg_t *pkg)
{
	const char *p;
	char fmt[32], buf[64];
	int len;

	for(p = cfg.format; *p; p++) {
		len = 0;
		if(*p == '%') {
			len = strspn(p + 1 + len, printf_flags);
			len += strspn(p + 1 + len, digits);
			snprintf(fmt, len + 3, "%ss", p);
			fmt[len + 1] = 's';
			p += len + 1;
			switch(*p) {
				/* simple attributes */
				case 'a':
					snprintf(buf, 64, "%ld", pkg->lastmod);
					printf(fmt, buf);
					break;
				case 'c':
					printf(fmt, category_id_to_string(pkg->cat));
					break;
				case 'd':
					printf(fmt, pkg->desc);
					break;
				case 'i':
					snprintf(buf, 64, "%d", pkg->id);
					printf(fmt, buf);
					break;
				case 'l':
					printf(fmt, pkg->lic);
					break;
				case 'm':
					printf(fmt, pkg->maint ? pkg->maint : "(orphan)");
					break;
				case 'n':
					printf(fmt, pkg->name);
					break;
				case 'o':
					snprintf(buf, 64, "%d", pkg->votes);
					printf(fmt, buf);
					break;
				case 'p':
					snprintf(buf, 64, AUR_PKG_URL_FORMAT "%s", pkg->name);
					printf(fmt, buf);
					break;
				case 's':
					snprintf(buf, 64, "%ld", pkg->firstsub);
					printf(fmt, buf);
					break;
				case 't':
					printf(fmt, pkg->ood ? "yes" : "no");
					break;
				case 'u':
					printf(fmt, pkg->url);
					break;
				case 'v':
					printf(fmt, pkg->ver);
					break;
				/* list based attributes */
				case 'C':
					print_extinfo_list(pkg->conflicts, NULL, cfg.delim, 0);
					break;
				case 'D':
					print_extinfo_list(pkg->depends, NULL, cfg.delim, 0);
					break;
				case 'M':
					print_extinfo_list(pkg->makedepends, NULL, cfg.delim, 0);
					break;
				case 'O':
					print_extinfo_list(pkg->optdepends, NULL, cfg.delim, 0);
					break;
				case 'P':
					print_extinfo_list(pkg->provides, NULL, cfg.delim, 0);
					break;
				case 'R':
					print_extinfo_list(pkg->replaces, NULL, cfg.delim, 0);
					break;
				case '%':
					fputc('%', stdout);
					break;
				default:
					fputc('?', stdout);
					break;
			}
		} else if(*p == '\\') {
			char ebuf[3];
			ebuf[0] = *p;
			ebuf[1] = *++p;
			ebuf[2] = '\0';
			print_escaped(ebuf);
		} else {
			fputc(*p, stdout);
		}
	}

	fputc('\n', stdout);

	return;
}

void print_pkg_info(struct aurpkg_t *pkg)
{
	char datestring[42];
	struct tm *ts;
	alpm_pkg_t *ipkg;

	printf("Repository     : %saur%s\n", colstr.repo, colstr.nc);
	printf("Name           : %s%s%s", colstr.pkg, pkg->name, colstr.nc);
	if((ipkg = alpm_db_get_pkg(db_local, pkg->name))) {
		const char *instcolor;
		if(alpm_pkg_vercmp(pkg->ver, alpm_pkg_get_version(ipkg)) > 0) {
			instcolor = colstr.ood;
		} else {
			instcolor = colstr.utd;
		}
		printf(" %s[%sinstalled%s]%s", colstr.url, instcolor, colstr.url, colstr.nc);
	}
	fputc('\n', stdout);

	printf("Version        : %s%s%s\n",
			pkg->ood ? colstr.ood : colstr.utd, pkg->ver, colstr.nc);
	printf("URL            : %s%s%s\n", colstr.url, pkg->url, colstr.nc);
	printf("AUR Page       : %s" AUR_PKG_URL_FORMAT "%s%s\n",
			colstr.url, pkg->name, colstr.nc);

	print_extinfo_list(pkg->depends, "Depends On", kListDelim, 1);
	print_extinfo_list(pkg->makedepends, "Makedepends", kListDelim, 1);
	print_extinfo_list(pkg->provides, "Provides", kListDelim, 1);
	print_extinfo_list(pkg->conflicts, "Conflicts With", kListDelim, 1);

	if(pkg->optdepends) {
		const alpm_list_t *i;
		printf("Optional Deps  : %s\n", (const char*)pkg->optdepends->data);
		for(i = pkg->optdepends->next; i; i = alpm_list_next(i)) {
			printf("%-*s%s\n", kInfoIndent, "", (const char*)i->data);
		}
	}

	print_extinfo_list(pkg->replaces, "Replaces", kListDelim, 1);

	printf("Category       : %s\n"
				 "License        : %s\n"
				 "Votes          : %d\n"
				 "Out of Date    : %s%s%s\n",
				 category_id_to_string(pkg->cat), pkg->lic, pkg->votes,
				 pkg->ood ? colstr.ood : colstr.utd,
				 pkg->ood ? "Yes" : "No", colstr.nc);

	printf("Maintainer     : %s\n", pkg->maint ? pkg->maint : "(orphan)");

	ts = localtime(&pkg->firstsub);
	strftime(datestring, 42, "%c", ts);
	printf("Submitted      : %s\n", datestring);

	ts = localtime(&pkg->lastmod);
	strftime(datestring, 42, "%c", ts);
	printf("Last Modified  : %s\n", datestring);

	printf("Description    : ");
	indentprint(pkg->desc, kInfoIndent);
	printf("\n\n");
}

void print_pkg_search(struct aurpkg_t *pkg)
{
	if(cfg.quiet) {
		printf("%s%s%s\n", colstr.pkg, pkg->name, colstr.nc);
	} else {
		alpm_pkg_t *ipkg;
		printf("%saur/%s%s%s %s%s%s%s (%d)", colstr.repo, colstr.nc, colstr.pkg,
				pkg->name, pkg->ood ? colstr.ood : colstr.utd, pkg->ver,
				NCFLAG(pkg->ood, " <!>"), colstr.nc, pkg->votes);
		if((ipkg = alpm_db_get_pkg(db_local, pkg->name))) {
			const char *instcolor;
			if(alpm_pkg_vercmp(pkg->ver, alpm_pkg_get_version(ipkg)) > 0) {
				instcolor = colstr.ood;
			} else {
				instcolor = colstr.utd;
			}
			printf(" %s[%sinstalled%s]%s", colstr.url, instcolor, colstr.url, colstr.nc);
		}
		printf("\n    ");
		indentprint(pkg->desc, kSearchIndent);
		fputc('\n', stdout);
	}
}

void print_results(alpm_list_t *results, void (*printfn)(struct aurpkg_t*))
{
	const alpm_list_t *i;
	struct aurpkg_t *prev = NULL;

	if(!printfn) {
		return;
	}

	if(!results && (cfg.opmask & OP_INFO)) {
		cwr_fprintf(stderr, LOG_ERROR, "no results found\n");
		return;
	}

	for(i = results; i; i = alpm_list_next(i)) {
		struct aurpkg_t *pkg = i->data;

		/* don't print duplicates */
		if(!prev || aurpkg_cmp(pkg, prev) != 0) {
			printfn(pkg);
		}
		prev = pkg;
	}
}

int resolve_dependencies(CURL *curl, const char *pkgname, const char *subdir)
{
	const alpm_list_t *i;
	alpm_list_t *deplist = NULL;
	char *filename, *pkgbuild;
	void *retval;

	curl = curl_init_easy_handle(curl);

	cwr_asprintf(&filename, "%s/%s/PKGBUILD", cfg.dlpath, subdir ? subdir : pkgname);

	pkgbuild = get_file_as_buffer(filename);
	if(!pkgbuild) {
		return 1;
	}

	alpm_list_t **pkg_details[PKGDETAIL_MAX] = {
		&deplist, &deplist, NULL, NULL, NULL, NULL
	};

	cwr_printf(LOG_DEBUG, "Parsing %s for extended info\n", filename);
	pkgbuild_get_extinfo(pkgbuild, pkg_details);
	free(pkgbuild);
	free(filename);

	for(i = deplist; i; i = alpm_list_next(i)) {
		const char *depend = i->data;
		char *sanitized = strdup(depend);

		sanitized[strcspn(sanitized, "<>=")] = '\0';

		if(!alpm_list_find_str(cfg.targets, sanitized)) {
			pthread_mutex_lock(&listlock);
			cfg.targets = alpm_list_add(cfg.targets, sanitized);
			pthread_mutex_unlock(&listlock);
		} else {
			if(cfg.logmask & LOG_BRIEF &&
							!alpm_find_satisfier(alpm_db_get_pkgcache(db_local), depend)) {
					cwr_printf(LOG_BRIEF, "S\t%s\n", sanitized);
			}
			free(sanitized);
		}

		if(sanitized) {
			if(alpm_find_satisfier(alpm_db_get_pkgcache(db_local), depend)) {
				cwr_printf(LOG_DEBUG, "%s is already satisified\n", depend);
			} else {
				if(!pkg_is_binary(depend)) {
					retval = task_download(curl, sanitized);
					alpm_list_free_inner(retval, aurpkg_free);
					alpm_list_free(retval);
				}
			}
		}
	}

	FREELIST(deplist);

	return 0;
}

int set_working_dir(void)
{
	char *resolved;

	if(!(cfg.opmask & OP_DOWNLOAD)) {
		free(cfg.dlpath);
		cfg.dlpath = NULL;
		return 0;
	}

	resolved = cfg.dlpath ? realpath(cfg.dlpath, NULL) : getcwd(NULL, 0);
	if(!resolved) {
		fprintf(stderr, "error: failed to resolve download path %s: %s\n",
				cfg.dlpath, strerror(errno));
		free(cfg.dlpath);
		cfg.dlpath = NULL;
		return 1;
	}

	free(cfg.dlpath);
	cfg.dlpath = resolved;

	if(access(cfg.dlpath, W_OK) != 0) {
		fprintf(stderr, "error: cannot write to %s: %s\n",
				cfg.dlpath, strerror(errno));
		free(cfg.dlpath);
		cfg.dlpath = NULL;
		return 1;
	}

	if(chdir(cfg.dlpath) != 0) {
		fprintf(stderr, "error: failed to chdir to %s: %s\n", cfg.dlpath,
				strerror(errno));
		return 1;
	}

	return 0;
}

int strings_init(void)
{
	if(cfg.color > 0) {
		colstr.error = BOLDRED "::" NC;
		colstr.warn = BOLDYELLOW "::" NC;
		colstr.info = BOLDBLUE "::" NC;
		colstr.pkg = BOLD;
		colstr.repo = BOLDMAGENTA;
		colstr.url = BOLDCYAN;
		colstr.ood = BOLDRED;
		colstr.utd = BOLDGREEN;
		colstr.nc = NC;
	}

	/* guard against delim being something other than kListDelim if extinfo
	 * and format aren't provided */
	cfg.delim = (cfg.extinfo && cfg.format) ? cfg.delim : kListDelim;

	return 0;
}

int string_to_key(const unsigned char *key, size_t len)
{
	char keybuf[32];
	struct key_t k;
	struct key_t *result;

	snprintf(keybuf, len + 1, "%s", key);

	k.name = keybuf;
	result = bsearch(&k, json_keys, sizeof(json_keys) / sizeof(json_keys[0]),
			sizeof(json_keys[0]), keycmp);

	return result ? result->id : -1;

}

size_t strtrim(char *str)
{
	char *left = str, *right;

	if(!str || *str == '\0') {
		return 0;
	}

	while(isspace((unsigned char)*left)) {
		left++;
	}
	if(left != str) {
		memmove(str, left, (strlen(left) + 1));
	}

	if(*str == '\0') {
		return 0;
	}

	right = (char*)rawmemchr(str, '\0') - 1;
	while(isspace((unsigned char)*right)) {
		right--;
	}
	*++right = '\0';

	return right - left;
}

void *task_download(CURL *curl, void *arg)
{
	if(pkg_is_binary(arg)) {
		return NULL;
	} else {
		return download(curl, arg);
	}
}

void *task_query(CURL *curl, void *arg)
{
	alpm_list_t *pkglist = NULL;
	CURLcode curlstat;
	struct yajl_handle_t *yajl_hand = NULL;
	const char *argstr;
	char *escaped, *url;
	long httpcode;
	int span = 0;
	struct yajl_parser_t *parse_struct;

	/* find a valid chunk of search string */
	if(cfg.opmask & OP_SEARCH) {
		for(argstr = arg; *argstr; argstr++) {
			span = strcspn(argstr, kRegexChars);

			/* given 'cow?', we can't include w in the search */
			if(argstr[span] == '?' || argstr[span] == '*') {
				span--;
			}

			/* a string inside [] or {} cannot be a valid span */
			if(strchr("[{", *argstr)) {
				argstr = strpbrk(argstr + span, "]}");
				if(!argstr) {
					cwr_fprintf(stderr, LOG_ERROR, "invalid regular expression: %s\n", (const char*)arg);
					return NULL;
				}
				continue;
			}

			if(span >= 2) {
				break;
			}
		}

		if(span < 2) {
			cwr_fprintf(stderr, LOG_ERROR, "search string '%s' too short\n", (const char*)arg);
			return NULL;
		}
	} else {
		argstr = arg;
	}

	parse_struct = calloc(1, sizeof(struct yajl_parser_t));
	parse_struct->aurpkg = calloc(1, sizeof(struct aurpkg_t));
	yajl_hand = yajl_alloc(&callbacks, NULL, (void*)parse_struct);

	curl = curl_init_easy_handle(curl);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, yajl_parse_stream);
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, yajl_hand);

	escaped = url_escape((char*)argstr, span, NULL);
	if(cfg.opmask & OP_SEARCH) {
		cwr_asprintf(&url, AUR_RPC_URL, "search", escaped);
	} else if(cfg.opmask & OP_MSEARCH) {
		cwr_asprintf(&url, AUR_RPC_URL, "msearch", escaped);
	} else {
		cwr_asprintf(&url, AUR_RPC_URL, "info", escaped);
	}
	curl_easy_setopt(curl, CURLOPT_URL, url);

	cwr_printf(LOG_DEBUG, "[%s]: curl_easy_perform %s\n", (const char *)arg, url);
	curlstat = curl_easy_perform(curl);

	if(curlstat != CURLE_OK) {
		cwr_fprintf(stderr, LOG_ERROR, "[%s]: %s\n", (const char*)arg,
				curl_easy_strerror(curlstat));
		goto finish;
	}

	curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpcode);
	cwr_printf(LOG_DEBUG, "[%s]: server responded with %ld\n", (const char *)arg, httpcode);
	if(httpcode >= 400) {
		cwr_fprintf(stderr, LOG_ERROR, "[%s]: server responded with HTTP %ld\n",
				(const char*)arg, httpcode);
		goto finish;
	}

	yajl_complete_parse(yajl_hand);
	if(parse_struct->error) {
		cwr_fprintf(stderr, LOG_ERROR, "[%s]: query failed: %s\n",
				(const char*)arg, parse_struct->error);
		goto finish;
	}

	pkglist = parse_struct->pkglist;

	if(pkglist && cfg.extinfo) {
		struct aurpkg_t *aurpkg;
		char *pburl, *escaped, *pkgbuild;

		aurpkg = pkglist->data;
		escaped = url_escape(aurpkg->urlpath, 0, "/");
		cwr_asprintf(&pburl, AUR_BASE_URL "%s", escaped);
		memcpy(strrchr(pburl, '/') + 1, "PKGBUILD\0", 9);

		pkgbuild = curl_get_url_as_buffer(curl, pburl);
		free(escaped);
		free(pburl);

		alpm_list_t **pkg_details[PKGDETAIL_MAX] = {
			&aurpkg->depends, &aurpkg->makedepends, &aurpkg->optdepends,
			&aurpkg->provides, &aurpkg->conflicts, &aurpkg->replaces
		};

		pkgbuild_get_extinfo(pkgbuild, pkg_details);
		free(pkgbuild);
	}

finish:
	yajl_free(yajl_hand);
	curl_free(escaped);
	free(parse_struct->aurpkg);
	free(parse_struct->error);
	free(parse_struct);
	free(url);

	return pkglist;
}

void *task_update(CURL *curl, void *arg)
{
	alpm_pkg_t *pmpkg;
	struct aurpkg_t *aurpkg;
	void *dlretval, *qretval;
	const char *candidate = arg;

	cwr_printf(LOG_VERBOSE, "Checking %s%s%s for updates...\n",
			colstr.pkg, candidate, colstr.nc);

	qretval = task_query(curl, arg);
	aurpkg = qretval ? ((alpm_list_t*)qretval)->data : NULL;
	if(aurpkg) {

		pmpkg = alpm_db_get_pkg(db_local, arg);

		if(!pmpkg) {
			cwr_fprintf(stderr, LOG_WARN, "skipping uninstalled package %s\n",
					candidate);
			goto finish;
		}

		if(alpm_pkg_vercmp(aurpkg->ver, alpm_pkg_get_version(pmpkg)) > 0) {
			if(alpm_list_find(cfg.ignore.pkgs, arg, globcompare)) {
				if(!cfg.quiet && !(cfg.logmask & LOG_BRIEF)) {
					cwr_fprintf(stderr, LOG_WARN, "%s%s%s [ignored] %s%s%s -> %s%s%s\n",
							colstr.pkg, candidate, colstr.nc,
							colstr.ood, alpm_pkg_get_version(pmpkg), colstr.nc,
							colstr.utd, aurpkg->ver, colstr.nc);
				}
				return NULL;
			}

			if(cfg.opmask & OP_DOWNLOAD) {
				/* we don't care about the return, but we do care about leaks */
				dlretval = task_download(curl, (void*)aurpkg->name);
				alpm_list_free_inner(dlretval, aurpkg_free);
				alpm_list_free(dlretval);
			} else {
				if(cfg.quiet) {
					printf("%s%s%s\n", colstr.pkg, candidate, colstr.nc);
				} else {
					cwr_printf(LOG_INFO, "%s%s %s%s%s -> %s%s%s\n",
							colstr.pkg, candidate,
							colstr.ood, alpm_pkg_get_version(pmpkg), colstr.nc,
							colstr.utd, aurpkg->ver, colstr.nc);
				}
			}

			return qretval;
		}
	}

finish:
	alpm_list_free_inner(qretval, aurpkg_free);
	alpm_list_free(qretval);
	return NULL;
}

void *thread_pool(void *arg)
{
	alpm_list_t *ret = NULL;
	CURL *curl;
	void *job;
	struct task_t *task = arg;

	curl = curl_easy_init();
	if(!curl) {
		cwr_fprintf(stderr, LOG_ERROR, "curl: failed to initialize handle\n");
		return NULL;
	}

	while(1) {
		job = NULL;

		/* try to pop off the work queue */
		pthread_mutex_lock(&listlock);
		if(workq) {
			job = workq->data;
			workq = alpm_list_next(workq);
		}
		pthread_mutex_unlock(&listlock);

		/* make sure we hooked a new job */
		if(!job) {
			break;
		}

		ret = alpm_list_join(ret, task->threadfn(curl, job));
	}

	curl_easy_cleanup(curl);

	return ret;
}

static char *url_escape(char *in, int len, const char *delim)
{
	char *tok, *escaped;
	char buf[2048] = { 0 };

	if(!delim) {
		return curl_easy_escape(NULL, in, len);
	}

	while((tok = strsep(&in, delim))) {
		escaped = curl_easy_escape(NULL, tok, 0);
		strcat(buf, escaped);
		curl_free(escaped);
		strcat(buf, delim);
	}

	return strndup(buf, strlen(buf) - 1);
}

void usage(void)
{
	fprintf(stderr, "cower %s\n"
	    "Usage: cower <operations> [options] target...\n\n", COWER_VERSION);
	fprintf(stderr,
	    " Operations:\n"
	    "  -d, --download          download target(s) -- pass twice to "
	                                 "download AUR dependencies\n"
	    "  -i, --info              show info for target(s) -- pass twice for "
	                                 "more detail\n"
	    "  -m, --msearch           show packages maintained by target(s)\n"
	    "  -s, --search            search for target(s)\n"
	    "  -u, --update            check for updates against AUR -- can be combined "
	                                 "with the -d flag\n\n");
	fprintf(stderr, " General options:\n"
	    "  -f, --force             overwrite existing files when downloading\n"
	    "  -h, --help              display this help and exit\n"
	    "      --ignore <pkg>      ignore a package upgrade (can be used more than once)\n"
	    "      --ignorerepo <repo> ignore some or all binary repos\n"
	    "  -t, --target <dir>      specify an alternate download directory\n"
	    "      --threads <num>     limit number of threads created\n"
	    "      --timeout <num>     specify connection timeout in seconds\n"
	    "  -V, --version           display version\n\n");
	fprintf(stderr, " Output options:\n"
	    "  -b, --brief             show output in a more script friendly format\n"
	    "  -c, --color[=WHEN]      use colored output. WHEN is `never', `always', or `auto'\n"
	    "      --debug             show debug output\n"
	    "      --format <string>   print package output according to format string\n"
	    "  -o, --ignore-ood        skip displaying out of date packages\n"
	    "      --no-ignore-ood     the opposite of --ignore-ood\n"
	    "      --sort <key>        sort results in ascending order by key\n"
	    "      --rsort <key>       sort results in descending order by key\n"
	    "      --listdelim <delim> change list format delimeter\n"
	    "  -q, --quiet             output less\n"
	    "  -v, --verbose           output more\n\n");
}

void version(void)
{
	fputs("\n  " COWER_VERSION "\n", stdout);
	fputs("     \\\n"
	      "      \\\n"
	      "        ,__, |    |\n"
	      "        (oo)\\|    |___\n"
	      "        (__)\\|    |   )\\_\n"
	      "          U  |    |_w |  \\\n"
	      "             |    |  ||   *\n"
	      "\n"
	      "             Cower....\n\n", stdout);
}

size_t yajl_parse_stream(void *ptr, size_t size, size_t nmemb, void *stream)
{
	struct yajl_handle_t *hand = stream;
	size_t realsize = size * nmemb;

	yajl_parse(hand, ptr, realsize);

	return realsize;
}

int read_targets_from_file(FILE *in, alpm_list_t **targets) {
	char line[BUFSIZ];
	int i = 0, end = 0;
	while(!end) {
		line[i] = fgetc(in);

		if(line[i] == EOF) {
			end = 1;
		}

		if(isspace(line[i]) || end) {
			line[i] = '\0';
			/* avoid adding zero length arg, if multiple spaces separate args */
			if(i > 0) {
				if(!alpm_list_find_str(*targets, line)) {
					cwr_printf(LOG_DEBUG, "adding target: %s\n", line);
					*targets = alpm_list_add(*targets, strdup(line));
				}
				i = 0;
			}
		} else {
			++i;
			if(i >= BUFSIZ) {
				cwr_fprintf(stderr, LOG_ERROR, "buffer overflow detected in stdin\n");
				return -1;
			}
		}
	}

	return 0;
}

int main(int argc, char *argv[]) {
	alpm_list_t *results = NULL, *thread_return = NULL;
	int ret, n, num_threads;
	pthread_t *threads;
	struct task_t task = {
		.printfn = NULL,
		.threadfn = task_query
	};

	setlocale(LC_ALL, "");

	/* initialize config */
	cfg.color = cfg.maxthreads = cfg.timeout = kUnset;
	cfg.delim = kListDelim;
	cfg.logmask = LOG_ERROR|LOG_WARN|LOG_INFO;
	cfg.ignoreood = kUnset;
	cfg.sort_fn = aurpkg_cmpname;
	cfg.sortorder = SORT_FORWARD;

	ret = parse_options(argc, argv);
	switch(ret) {
		case 0: /* everything's cool */
			break;
		case 3:
			fprintf(stderr, "error: no operation specified (use -h for help)\n");
		case 1: /* these provide their own error mesg */
			return ret;
	}

	if(parse_configfile() != 0) {
		return 1;
	}

	/* fallback from sentinel values */
	cfg.maxthreads = cfg.maxthreads == kUnset ? kThreadDefault : cfg.maxthreads;
	cfg.timeout = cfg.timeout == kUnset ? kTimeoutDefault : cfg.timeout;
	cfg.color = cfg.color == kUnset ? 0 : cfg.color;
	cfg.ignoreood = cfg.ignoreood == kUnset ? 0 : cfg.ignoreood;

	if(strings_init() != 0) {
		return 1;
	}

	if(cfg.frompkgbuild) {
		/* treat arguments as filenames to load/extract */
		cfg.targets = load_targets_from_files(cfg.targets);
	} else if(alpm_list_find_str(cfg.targets, "-")) {
		char *vdata;
		cfg.targets = alpm_list_remove_str(cfg.targets, "-", &vdata);
		free(vdata);
		cwr_printf(LOG_DEBUG, "reading targets from stdin\n");
		ret = read_targets_from_file(stdin, &cfg.targets);
		if(ret != 0) {
			goto finish;
		}
		if(!freopen(ctermid(NULL), "r", stdin)) {
			cwr_printf(LOG_DEBUG, "failed to reopen stdin for reading\n");
		}
	}

	ret = set_working_dir();
	if(ret != 0) {
		goto finish;
	}

	cwr_printf(LOG_DEBUG, "initializing curl\n");
	ret = curl_global_init(CURL_GLOBAL_ALL);
	openssl_crypto_init();

	if(ret != 0) {
		cwr_fprintf(stderr, LOG_ERROR, "failed to initialize curl\n");
		goto finish;
	}

	pmhandle = alpm_init();
	if(!pmhandle) {
		cwr_fprintf(stderr, LOG_ERROR, "failed to initialize alpm library\n");
		goto finish;
	}

	/* allow specific updates to be provided instead of examining all foreign pkgs */
	if((cfg.opmask & OP_UPDATE) && !cfg.targets) {
		cfg.targets = alpm_find_foreign_pkgs();
		if(cfg.targets == NULL) {
			/* no foreign packages found, just exit */
			goto finish;
		}
	}

	workq = cfg.targets;
	num_threads = alpm_list_count(cfg.targets);
	if(num_threads == 0) {
		fprintf(stderr, "error: no targets specified (use -h for help)\n");
		goto finish;
	} else if(num_threads > cfg.maxthreads) {
		num_threads = cfg.maxthreads;
	}

	threads = malloc(num_threads * sizeof(pthread_t));
	if(threads == NULL) {
		cwr_fprintf(stderr, LOG_ERROR, "could not allocate memory for threads\n");
		goto finish;
	}

	/* override task behavior */
	if(cfg.opmask & OP_UPDATE) {
		task.threadfn = task_update;
	} else if(cfg.opmask & OP_INFO) {
		task.printfn = cfg.format ? print_pkg_formatted : print_pkg_info;
	} else if(cfg.opmask & (OP_SEARCH|OP_MSEARCH)) {
		task.printfn = cfg.format ? print_pkg_formatted : print_pkg_search;
	} else if(cfg.opmask & OP_DOWNLOAD) {
		task.threadfn = task_download;
	}

	/* filthy, filthy hack: prepopulate the package cache */
	alpm_db_get_pkgcache(db_local);

	for(n = 0; n < num_threads; n++) {
		ret = pthread_create(&threads[n], NULL, thread_pool, &task);
		if(ret != 0) {
			cwr_fprintf(stderr, LOG_ERROR, "failed to spawn new thread: %s\n",
					strerror(ret));
			return(ret); /* we don't want to recover from this */
		}
	}

	for(n = 0; n < num_threads; n++) {
		pthread_join(threads[n], (void**)&thread_return);
		results = alpm_list_join(results, thread_return);
	}
	free(threads);

	/* we need to exit with a non-zero value when:
	 * a) search/info/download returns nothing
	 * b) update (without download) returns something
	 * this is opposing behavior, so just XOR the result on a pure update */
	results = filter_results(results);
	ret = ((results == NULL) ^ !(cfg.opmask & ~OP_UPDATE));
	print_results(results, task.printfn);
	alpm_list_free_inner(results, aurpkg_free);
	alpm_list_free(results);

	openssl_crypto_cleanup();

finish:
	free(cfg.dlpath);
	FREELIST(cfg.targets);
	FREELIST(cfg.ignore.pkgs);
	FREELIST(cfg.ignore.repos);

	cwr_printf(LOG_DEBUG, "releasing curl\n");
	curl_global_cleanup();

	cwr_printf(LOG_DEBUG, "releasing alpm\n");
	alpm_release(pmhandle);

	return ret;
}

/* vim: set noet ts=2 sw=2: */
