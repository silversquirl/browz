// TODO: write buildtime code to generate this file from litehtml.zig

#pragma once

#include <cstddef>

extern "C" {

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
	WebColor color;
	Position pos;
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
	WebColor color;
};

struct Borders {
	Border left;
	Border top;
	Border right;
	Border bottom;
	BorderRadiuses radius;
};

struct BackgroundPaint {
	size_t image_len;
	const char *image;
	size_t baseurl_len;
	const char *baseurl;
	int attachment;
	int repeat;
	WebColor color;
	Position clip_box;
	Position origin_box;
	Position border_box;
	BorderRadiuses border_radius;
	Size image_size;
	int position_x;
	int position_y;
	bool is_root;
};

//// Document Container ////

struct DocumentContainer;
size_t dcCreateFont(
	DocumentContainer *,
	const char *face_name,
	int size,
	int weight,
	bool italic,
	unsigned char decoration,
	FontMetrics *metrics
);
void dcDeleteFont(DocumentContainer *, size_t font_h);
int dcTextWidth(DocumentContainer *, const char *text, size_t font_h);
void dcDrawText(
	DocumentContainer *,
	size_t hdc,
	const char *text,
	size_t font_h,
	WebColor color,
	Position pos
);

int dcPtToPx(DocumentContainer *, int pt);
int dcGetDefaultFontSize(DocumentContainer *);
const char *dcGetDefaultFontName(DocumentContainer *);

void dcLoadImage(DocumentContainer *, const char *src, const char *base_url, bool redraw_on_ready);
Size dcGetImageSize(DocumentContainer *, const char *src, const char *baseurl);

void dcDrawListMarker(DocumentContainer *, size_t hdc, const ListMarker *marker);
void dcDrawBackground(DocumentContainer *, size_t hdc, const BackgroundPaint *bg);
void dcDrawBorders(
	DocumentContainer *,
	size_t hdc,
	const Borders *borders,
	Position draw_pos,
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
int renderDocument(Document *zig_doc, int max_width);
void drawDocument(Document *zig_doc, size_t hdc, int x, int y, Position clip);

}
