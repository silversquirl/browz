#pragma once

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

struct FontMetrics {
    int height;
    int ascent;
    int descent;
    int x_height;
    bool draw_spaces;
};

struct WebColor {
    uint8_t blue;
    uint8_t green;
    uint8_t red;
    uint8_t alpha;
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

struct DocumentContainer {
	size_t (*createFont)(
		DocumentContainer *,
		const char *face_name,
		int size,
		int weight,
		bool italic,
		unsigned int decoration,
		FontMetrics *metrics
	);
	void (*deleteFont)(DocumentContainer *, size_t font_h);
	int (*textWidth)(DocumentContainer *, const char *text, size_t font_h);
	void (*drawText)(
		DocumentContainer *,
		size_t hdc,
		const char *text,
		size_t font_h,
		WebColor color,
		Position pos
	);

	int (*ptToPx)(DocumentContainer *, int pt);
	int (*getDefaultFontSize)(DocumentContainer *);
	const char *(*getDefaultFontName)(DocumentContainer *);

	void (*loadImage)(DocumentContainer *, const char *src, const char *base_url, bool redraw_on_ready);
	Size (*getImageSize)(DocumentContainer *, const char *src, const char *baseurl);

	void (*drawListMarker)(DocumentContainer *, size_t hdc, const ListMarker *marker);
	void (*drawBackground)(DocumentContainer *, size_t hdc, const BackgroundPaint *bg);
	void (*drawBorders)(
		DocumentContainer *,
		size_t hdc,
		const Borders *borders,
		Position draw_pos,
		bool root
	);
};

#ifdef __cplusplus
}
#endif
