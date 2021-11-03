// TODO: write buildtime code to generate this file from litehtml.zig

#pragma once

#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

//// Types ////

struct FontMetrics {
    int height;
    int ascent;
    int descent;
    int x_height;
    bool draw_spaces;
};

struct WebColor {
    unsigned char blue;
    unsigned char green;
    unsigned char red;
    unsigned char alpha;
};

struct Position {
    int x;
    int y;
    int width;
    int height;
};

struct Size {
    int width;
    int height;
};

struct ListMarker {
	size_t image_len;
	const char *image;
	const char *baseurl;
	int marker_type;
	struct WebColor color;
	struct Position pos;
	int index;
	size_t font;
};

struct BorderRadiuses {
	int top_left_x;
	int top_left_y;

	int top_right_x;
	int top_right_y;

	int bottom_right_x;
	int bottom_right_y;

	int bottom_left_x;
	int bottom_left_y;
};

struct Border {
	int width;
	int style;
	struct WebColor color;
};

struct Borders {
	struct Border left;
	struct Border top;
	struct Border right;
	struct Border bottom;
	struct BorderRadiuses radius;
};

struct BackgroundPaint {
	size_t image_len;
	const char *image;
	size_t baseurl_len;
	const char *baseurl;
	int attachment;
	int repeat;
	struct WebColor color;
	struct Position clip_box;
	struct Position origin_box;
	struct Position border_box;
	struct BorderRadiuses border_radius;
	struct Size image_size;
	int position_x;
	int position_y;
	bool is_root;
};

//// Document Container ////

struct DocumentContainer;
size_t dcCreateFont(
	struct DocumentContainer *,
	const char *face_name,
	int size,
	int weight,
	bool italic,
	unsigned char decoration,
	struct FontMetrics *metrics
);
void dcDeleteFont(struct DocumentContainer *, size_t font_h);
int dcTextWidth(struct DocumentContainer *, const char *text, size_t font_h);
void dcDrawText(
	struct DocumentContainer *,
	size_t hdc,
	const char *text,
	size_t font_h,
	struct WebColor color,
	struct Position pos
);

int dcPtToPx(struct DocumentContainer *, int pt);
int dcGetDefaultFontSize(struct DocumentContainer *);
const char *dcGetDefaultFontName(struct DocumentContainer *);

void dcLoadImage(struct DocumentContainer *, const char *src, const char *base_url, bool redraw_on_ready);
struct Size dcGetImageSize(struct DocumentContainer *, const char *src, const char *baseurl);

void dcDrawListMarker(struct DocumentContainer *, size_t hdc, const struct ListMarker *marker);
void dcDrawBackground(struct DocumentContainer *, size_t hdc, const struct BackgroundPaint *bg);
void dcDrawBorders(
	struct DocumentContainer *,
	size_t hdc,
	const struct Borders *borders,
	struct Position draw_pos,
	bool root
);

//// Class wrappers ////

struct Context;
Context *createContext(void);
void destroyContext(Context *);
void loadMasterStylesheet(Context *, const char *);

struct Document;
Document *createDocument(const char *, DocumentContainer *, Context *);
void destroyDocument(Document *);

#ifdef __cplusplus
}
#endif
