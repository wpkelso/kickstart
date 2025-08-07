/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 William Kelso <wpkelso@posteo.net>
 */

public class AppWindow : Gtk.Window {
    
    private Gtk.EntryBuffer buf = new Gtk.EntryBuffer ();
    private Gtk.Box main_view;

    private Gtk.ListBox results_list;
    private Gtk.ScrolledWindow results_view;

    public Backend.AppInfo app_backend { get; set; default = null; }

    int interval = 1;
    uint debounce_timer_id = 0;

    construct {

        var entry = new Gtk.Entry.with_buffer (buf) {
            primary_icon_name = "system-search-symbolic",
            placeholder_text = "Search for something…",
            margin_start = 6,
            margin_end = 6,
            margin_top = 6,
            margin_bottom = 6,
        };

        main_view = new Gtk.Box (VERTICAL, 1);
        main_view.append (entry);


        child = main_view;
        resizable = false;
        vexpand = true;
        default_width = 800;
        titlebar = new Gtk.Grid ();

        results_list = new Gtk.ListBox () {
            show_separators = true,
            selection_mode = Gtk.SelectionMode.BROWSE,
        };

        results_view = new Gtk.ScrolledWindow () {
            margin_start = 6,
            margin_end = 6,
            margin_bottom = 6,
            min_content_height = 128,
        };

        entry.changed.connect (on_entry_modified);
    }

    private void on_entry_modified () {
        debug ("Beginning debug timer…");

        if (debounce_timer_id != 0) {
            GLib.Source.remove (debounce_timer_id);
        }

        debounce_timer_id = Timeout.add_seconds (interval, () => {
            debounce_timer_id = 0;
            var target = buf.get_text ();
            debug ("Searching for: %s", target);
            queue_searches (target);
            
            return GLib.Source.REMOVE;
        });
    }

    private void queue_searches (string target) {
            
            var results_box = new Gtk.Box (VERTICAL, 0) {
                vexpand = true,
            };

            var app_results = app_backend.simple_search (target);

            if (target.length > 0) {
                foreach (var result in app_results) {
                    if (!result.should_show ()) { continue; }

                    var new_list_row = new Gtk.ListBoxRow (); 
                    var row_box = new Granite.Box (HORIZONTAL);

                    var icon = result.get_icon ();
                    row_box.append (new Gtk.Image.from_gicon (icon));
                    var display_name = result.get_display_name ();
                    row_box.append (new Gtk.Label (display_name));

                    new_list_row.set_child (row_box);
                    results_box.append (new_list_row);
                }
                results_view.set_child  (results_box);
                main_view.append (results_view);
            } else {
                main_view.remove (results_view);
            }

    }

}
