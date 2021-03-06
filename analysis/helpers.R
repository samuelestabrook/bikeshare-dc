capital_hex = "#146EFF"
# change this!!!
orange_hex = "#FF5910"

if (all(c("Open Sans", "PT Sans") %in% fonts())) {
  font_family = "Open Sans"
  title_font_family = "PT Sans"
} else {
  font_family = "Arial"
  title_font_family = "Arial"
}

capitalbike_con = dbConnect(dbDriver("PostgreSQL"), dbname = "bikesharedb", host = "localhost")

query = function(sql, con = capitalbike_con) {
  fetch(dbSendQuery(con, sql), n = 1e8)
}

#add_credits = function(fontsize = 12, color = "#777777", xpos = 0.99, ypos = 0.02) {
#  grid.text("toddwschneider.com",
#            x = xpos,
#            y = ypos,
#            just = "right",
#            gp = gpar(fontsize = fontsize,
#                      fontfamily = font_family,
#                      col = color))
#}

title_with_subtitle = function(title, subtitle = NA) {
  if (is.na(subtitle)) {
    ggtitle(bquote(bold(.(title))))
  } else {
    ggtitle(bquote(atop(bold(.(title)), atop(.(subtitle)))))
  }
}

to_slug = function(string) {
  gsub("-", "_", gsub(" ", "_", tolower(string)))
}

theme_tws = function(base_size = 12) {
  bg_color = "#f4f4f4"
  bg_rect = element_rect(fill = bg_color, color = bg_color)

  theme_bw(base_size) +
    theme(text = element_text(family = font_family),
          plot.title = element_text(family = title_font_family),
          plot.background = bg_rect,
          panel.background = bg_rect,
          legend.background = bg_rect,
          panel.grid.major = element_line(colour = "grey80", size = 0.25),
          panel.grid.minor = element_line(colour = "grey80", size = 0.25),
          legend.key.width = unit(1.5, "line"),
          legend.key = element_blank())
}

to_slug = function(string) {
  gsub("__", "_", gsub("___", "_", gsub("__", "_", gsub("\\.", "_", gsub("\'", "_", gsub("&", "_", gsub("-", "_", gsub("/", "_", gsub(" ", "_", tolower(string))))))))))
}

#theme_dark_map = function(base_size = 12) {
#  theme_bw(base_size) +
#    theme(text = element_text(family = font_family, color = "#ffffff"),
#          rect = element_rect(fill = "#000000", color = "#000000"),
#          plot.background = element_rect(fill = "#000000", color = "#000000"),
#          panel.background = element_rect(fill = "#000000", color = "#000000"),
#          plot.title = element_text(family = title_font_family),
#          panel.grid = element_blank(),
#          panel.border = element_blank(),
#          axis.text = element_blank(),
#          axis.title = element_blank(),
#          axis.ticks = element_blank())
#}
