/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 William Kelso <wpkelso@posteo.net>
 */

public class AppBox : Granite.Box {
    public AppInfo info { get; construct; default = null; }
    public Icon icon { get; construct; default = null; }
    public string display_name { get; construct; default = null; }

    public AppBox (AppInfo info, Icon icon, string display_name) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            child_spacing: Granite.Box.Spacing.SINGLE,
            info: info,
            icon: icon,
            display_name: display_name
        );
    }

    construct {
        append (new Gtk.Image.from_gicon (icon));
        append (new Gtk.Label (display_name));
    }
}

public class AppWindow : Gtk.Window {
    
    private Gtk.EntryBuffer buf = new Gtk.EntryBuffer ();
    private Gtk.Box main_view;

    private Gtk.ListBox results_list;
    private Gtk.ScrolledWindow results_view;

    public Backend.AppInfo app_backend { get; set; default = null; }

    int interval = 1;
    uint debounce_timer_id = 0;

    private Gee.HashMap<string, AppInfo> current_results;

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

        current_results = new Gee.HashMap<string, AppInfo> ();

        results_list = new Gtk.ListBox () {
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.BROWSE,
        };

        results_view = new Gtk.ScrolledWindow () {
            margin_start = 6,
            margin_end = 6,
            margin_bottom = 6,
            min_content_height = 128,
        };

        entry.changed.connect (on_entry_modified);
        results_list.row_activated.connect (on_row_activated);
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

    private void on_row_activated () {
        var selected = results_list.get_selected_row ();
        var child = selected.get_child () as AppBox;
        var name = child.info.get_id ();
        debug ("Row was activated: %s", name);

        try {
            child.info.launch (null, null);
            close ();
        } catch (Error err) {
            warning ("Couldn't launch application: %s", err.message);
        }
        
    }

    private void queue_searches (string target) {

            current_results = app_backend.simple_search (target);
            results_list.remove_all ();

            if (target.length > 0) {
                foreach (var result in current_results) {
                    if (!result.value.should_show ()) { continue; }

                    var icon = result.value.get_icon ();
                    var display_name = result.value.get_display_name ();
                    var row_box = new AppBox (result.value, icon, display_name);

                    results_list.append (row_box);
                }
                results_view.set_child  (results_list);
                main_view.append (results_view);
            } else {
                main_view.remove (results_view);
            }

    }

}
