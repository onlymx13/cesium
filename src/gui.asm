gui_main:
	call	gui_draw_core
	draw_rectangle_outline 193, 24, 316, 221
	draw_rectangle_outline 237, 54, 274, 91
	draw_horiz 199, 36, 112
	set_normal_text
	print	string_file_information, 199, 27
	ld	a,(current_screen)
	cp	a,screen_programs
	jp	z,view_programs
	cp	a,screen_apps
	jp	z,view_apps
	;cp	a,screen_usb
	;jr	z,show_usb
	jp	exit_full

gui_draw_core:
	call	lcd_fill
	call	util_show_free_mem
	draw_rectangle 1, 1, 319, 21
	draw_rectangle_outline 1, 22, 318, 223
	set_inverted_text
	print string_cesium, 15, 7
	draw_sprite sprite_battery, 3, 7
	ld	a,0
battery_status := $-1
	sub	a,5
	cpl
	or	a,a
	ret	z
	ld	bc,4
	ld	de,(lcdWidth * 8) + 7
	jp	lcd_rectangle.computed

gui_draw_cesium_info:
	call	gui_draw_core
	call	gui_clear_status_bar
	set_inverted_text
	print	string_cesium_version, 4, 228
	set_normal_text
	ret

gui_show_description:
	push	bc
	push	hl
	call	gui_clear_status_bar
	pop	hl
	save_cursor
	set_inverted_text
	ld	bc,4
	ld	a,228
	call	util_string_xy
	set_normal_text
	restore_cursor
	pop	bc
	ret

; z flag set = option is on
; a = index
gui_draw_highlightable_option:
	push	af
	ld	ix,current_option_selection
	cp	a,(ix)
	ld	ix,color_secondary
	ld	a,(ix)
	ld	(.color_save),a
	jr	nz,.no_highlight
	ld	(ix),color_highlight
.no_highlight:
	pop	af
	call	gui_draw_option
	ld	a,0
.color_save := $-1
	ld	(color_secondary),a
	ret

gui_draw_option:
	push	af
	push	hl
	push	bc
	push	de
	call	lcd_rectangle_outline.computed
	pop	hl
	pop	bc
	dec	bc
	dec	bc
	dec	bc
	dec	bc				; bc - 4
	ld	a,h
	sub	a,4
	ld	(.recompute),a
	inc	l				; Ty + 3
	inc	l
	ld	h,lcdWidth / 2
	mlt	hl
	add	hl,hl
	pop	de
	add	hl,de
	ex	de,hl				; recompute offset
	inc	e
	inc	e
	pop	af
	ld	a,0
.recompute := $-1
	jp	nz,lcd_rectangle.computed
	ret

gui_draw_color_tables:
	draw_rectangle_outline 60, 71, 157, 168
	draw_rectangle_outline 163, 71, 260, 168
	ld	de,(72 shl 8) or 61
	ld	b,2
.double:
	push	bc
	ld	a,e
	ld	(.x),a
	xor	a,a
	ld	b,16
.loop:
	push	bc
	ld	b,6
.vert:
	push	bc
	ld	l,lcdWidth / 2
	ld	h,d
	mlt	hl
	add	hl,hl
	push	de
	ld	d,0
	add	hl,de
	ld	de,vRamBuffer
	add	hl,de
	pop	de
	ld	b,16
.horiz:
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	inc	a
	djnz	.horiz
	sub	a,16
	ld	e,0
.x := $-1
	inc	d
	pop	bc
	djnz	.vert
	pop	bc
	add	a,16
	djnz	.loop
	pop	bc
	ld	de,(72 shl 8) or 164
	djnz	.double

gui_draw_color_box:
	ld	bc,6					; width
	ld	a,(color_selection_y)
	ld	e,a
	ld	d,c
	mlt	de
	ld	a,e
	add	a,72
	ld	e,a					; y
	ld	a,(color_selection_x)
	ld	l,a
	ld	h,c
	mlt	hl
	ld	bc,61
color_table_active := $-3
	add	hl,bc					; x
	ld	c,6
	ld	d,c
.store_color:
	push	hl
	push	de
	push	bc
	call	lcd_compute
	ld	de,lcdWidth * 2 + 3
	add	hl,de
	ld	a,(hl)					; get the new color
	ld	(hl),0
	ld	hl,(color_ptr)
	ld	(hl),a
	pop	bc
	pop	de
	pop	hl
	ld	a,(color_secondary)
	push	af
	ld	a,0
	ld	(color_secondary),a
	call	lcd_rectangle_outline.computed
	pop	af
	ld	(color_secondary),a
	ret

color_ptr := $
	dl	0

gui_clear_status_bar:
	draw_rectangle 1, 225, 319, 239
	ret