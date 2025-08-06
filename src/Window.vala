/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 William Kelso <wpkelso@posteo.net>
 */

public class AppWindow : Gtk.Window {
    
    private Gtk.EntryBuffer buf = new Gtk.EntryBuffer ();
    private Gtk.Paned paned;
    private Gtk.ListView results_list;

    int interval = 1;
    uint debounce_timer_id = 0;

    construct {

        var entry = new Gtk.Entry.with_buffer (buf) {
            primary_icon_name = "system-search-symbolic",
            placeholder_text = "Search for something…",
        };

        paned = new Gtk.Paned (VERTICAL) {
            start_child = entry,
        };

        child = paned;
        resizable = false;
        vexpand = true;
        default_width = 800;
        titlebar = new Gtk.Grid ();

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
        
            if (target.length > 0) {
                paned.set_end_child (new Gtk.Label ("Results for " + target + " will show up here…"));
            } else {
                paned.set_end_child (null);
            }
            
            return GLib.Source.REMOVE;
        });
    }

}
