// TODO: clean up this mess of horrible copypaste
// In my defense, doing it this way meant the least amount of time spent writing C++

#include <cstdint>
#include <litehtml.h>
#include "litehtml_wrapper.h"

using namespace litehtml;

class DocumentContainerWrapper : document_container {
public:
	virtual uint_ptr create_font(
		const tchar_t *faceName,
		int size,
		int weight,
		font_style italic,
		unsigned int decoration,
		font_metrics *fm
	) override {
		FontMetrics metrics;
		size_t font = dc->createFont(
			dc,
			faceName,
			size,
			weight,
			italic == fontStyleItalic,
			decoration,
			&metrics
		);
		fm->height = metrics.height;
		fm->ascent = metrics.ascent;
		fm->descent = metrics.descent;
		fm->x_height = metrics.x_height;
		fm->draw_spaces = metrics.draw_spaces;
		return font;
	}

	virtual void delete_font(uint_ptr hFont) override {
		dc->deleteFont(dc, hFont);
	}

	virtual int text_width(const tchar_t *text, uint_ptr hFont) override {
		return dc->textWidth(dc, text, hFont);
	}

	virtual void draw_text(
		uint_ptr hdc,
		const tchar_t* text,
		uint_ptr hFont,
		web_color color,
		const position &pos
	) override {
		WebColor zig_color = { color.blue, color.green, color.red, color.alpha };
		Position zig_pos = { pos.x, pos.y, pos.width, pos.height };
		dc->drawText(dc, hdc, text, hFont, zig_color, zig_pos);
	}

	virtual int pt_to_px(int pt) override {
		return dc->ptToPx(dc, pt);
	}
	virtual int get_default_font_size() const override {
		return dc->getDefaultFontSize(dc);
	}
	virtual const tchar_t *get_default_font_name() const override {
		return dc->getDefaultFontName(dc);
	}

	virtual void draw_list_marker(uint_ptr hdc, const list_marker &marker) override {
		ListMarker zig_marker = {
			.image_len = marker.image.length(),
			.image = marker.image.data(),
			.baseurl = marker.baseurl,
			.marker_type = marker.marker_type,
			.color = {
				marker.color.blue,
				marker.color.green,
				marker.color.red,
				marker.color.alpha,
			},
			.pos = {
				marker.pos.x,
				marker.pos.y,
				marker.pos.width,
				marker.pos.height,
			},
			.index = marker.index,
			.font = marker.font,
		};
		return dc->drawListMarker(dc, hdc, &zig_marker);
	}

	virtual void load_image(const tchar_t *src, const tchar_t *baseurl, bool redraw_on_ready) override {
		dc->loadImage(dc, src, baseurl, redraw_on_ready);
	}
	virtual void get_image_size(const tchar_t *src, const tchar_t *baseurl, size &sz) override {
		Size zig_sz = dc->getImageSize(dc, src, baseurl);
		sz.width = zig_sz.width;
		sz.height = zig_sz.height;
	}
	virtual void draw_background(uint_ptr hdc, const background_paint &bg) override {
		BackgroundPaint zig_bg = {
			.image_len = bg.image.length(),
			.image = bg.image.data(),
			.baseurl_len = bg.baseurl.length(),
			.baseurl = bg.baseurl.data(),
			.attachment = bg.attachment,
			.repeat = bg.repeat,
			.color = {
				bg.color.blue,
				bg.color.green,
				bg.color.red,
				bg.color.alpha,
			},
			.clip_box = {
				bg.clip_box.x,
				bg.clip_box.y,
				bg.clip_box.width,
				bg.clip_box.height,
			},
			.origin_box = {
				bg.origin_box.x,
				bg.origin_box.y,
				bg.origin_box.width,
				bg.origin_box.height,
			},
			.border_box = {
				bg.border_box.x,
				bg.border_box.y,
				bg.border_box.width,
				bg.border_box.height,
			},
			.border_radius = {
				.top_left_x = bg.border_radius.top_left_x,
				.top_left_y = bg.border_radius.top_left_y,
				.top_right_x = bg.border_radius.top_right_x,
				.top_right_y = bg.border_radius.top_right_y,
				.bottom_right_x = bg.border_radius.bottom_right_x,
				.bottom_right_y = bg.border_radius.bottom_right_y,
				.bottom_left_x = bg.border_radius.bottom_left_x,
				.bottom_left_y = bg.border_radius.bottom_left_y,
			},
			.image_size = {
				bg.image_size.width,
				bg.image_size.height,
			},
			.position_x = bg.position_x,
			.position_y = bg.position_y,
			.is_root = bg.is_root,
		};
		dc->drawBackground(dc, hdc, &zig_bg);
	}
	virtual void draw_borders(uint_ptr hdc, const borders &borders, const position &draw_pos, bool root) override {
		Borders zig_borders = {
			.left = {
				borders.left.width,
				borders.left.style,
				{
					borders.left.color.blue,
					borders.left.color.green,
					borders.left.color.red,
					borders.left.color.alpha,
				},
			},
			.top = {
				borders.top.width,
				borders.top.style,
				{
					borders.top.color.blue,
					borders.top.color.green,
					borders.top.color.red,
					borders.top.color.alpha,
				},
			},
			.right = {
				borders.right.width,
				borders.right.style,
				{
					borders.right.color.blue,
					borders.right.color.green,
					borders.right.color.red,
					borders.right.color.alpha,
				},
			},
			.bottom = {
				borders.bottom.width,
				borders.bottom.style,
				{
					borders.bottom.color.blue,
					borders.bottom.color.green,
					borders.bottom.color.red,
					borders.bottom.color.alpha,
				},
			},
			.radius = {
				.top_left_x = borders.radius.top_left_x,
				.top_left_y = borders.radius.top_left_y,
				.top_right_x = borders.radius.top_right_x,
				.top_right_y = borders.radius.top_right_y,
				.bottom_right_x = borders.radius.bottom_right_x,
				.bottom_right_y = borders.radius.bottom_right_y,
				.bottom_left_x = borders.radius.bottom_left_x,
				.bottom_left_y = borders.radius.bottom_left_y,
			},
		};
		dc->drawBorders(dc, hdc, &zig_borders, {
			draw_pos.x,
			draw_pos.y,
			draw_pos.width,
			draw_pos.height,
		}, root);
	}

	virtual void set_caption(const tchar_t *caption) override = 0;
	virtual void set_base_url(const tchar_t *base_url) override = 0;
	virtual void link(const std::shared_ptr<document> &doc, const element::ptr &el) override = 0;
	virtual void on_anchor_click(const tchar_t *url, const element::ptr &el) override = 0;
	virtual void set_cursor(const tchar_t *cursor) override = 0;
	virtual void transform_text(tstring &text, text_transform tt) override = 0;
	virtual void import_css(tstring &text, const tstring &url, tstring &baseurl) override = 0;
	virtual void set_clip(const position &pos, const border_radiuses &bdr_radius, bool valid_x, bool valid_y) override = 0;
	virtual void del_clip() override = 0;
	virtual void get_client_rect(position &client) const override = 0;
	virtual std::shared_ptr<element> create_element(const tchar_t *tag_name, const string_map &attributes, const std::shared_ptr<document> &doc) override = 0;

	virtual void get_media_features(media_features &media) const override = 0;
	virtual void get_language(tstring &language, tstring &culture) const override = 0;
	virtual tstring resolve_color(const tstring &color_str) const override { return tstring(); }
	virtual void split_text(const char *text, std::function<void(const tchar_t *)> on_word, std::function<void(const tchar_t *)> on_space) override;

private:
	DocumentContainer *dc;
};

Context *createContext(void) {
	return (Context *)new context;
}
void destroyContext(Context *zig_ctx) {
	context *ctx = (context *)zig_ctx;
	delete ctx;
}
void loadMasterStylesheet(Context *zig_ctx, const char *str) {
	context *ctx = (context *)zig_ctx;
	ctx->load_master_stylesheet(str);
}
