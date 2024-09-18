using Gee;
using Gtk;

using Dino.Entities;
using Xmpp.Xep;

namespace Dino.Ui.Util {
    public Adw.PreferencesGroup rows_to_preference_group(GLib.ListStore row_view_models, string title) {
        var preference_group = new Adw.PreferencesGroup() { title=title };

        for (int preference_group_i = 0; preference_group_i < row_view_models.get_n_items(); preference_group_i++) {
            var preferences_row = (ViewModel.PreferencesRow.Any) row_view_models.get_item(preference_group_i);

            Widget? w = null;

            var entry_view_model = preferences_row as ViewModel.PreferencesRow.Entry;
            if (entry_view_model != null) {
                Adw.EntryRow view = new Adw.EntryRow() { title = entry_view_model.title, show_apply_button=true };
                entry_view_model.bind_property("text", view, "text", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL, (_, from, ref to) => {
                    var str = (string) from;
                    to = str ?? "";
                    return true;
                });
                view.apply.connect(() => {
                    entry_view_model.changed();
                });
                w = view;
            }

            var password_view_model = preferences_row as ViewModel.PreferencesRow.PrivateText;
            if (password_view_model != null) {
                Adw.PasswordEntryRow view = new Adw.PasswordEntryRow() { title = password_view_model.title, show_apply_button=true };
                password_view_model.bind_property("text", view, "text", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL, (_, from, ref to) => {
                    var str = (string) from;
                    to = str ?? "";
                    return true;
                });
                view.apply.connect(() => {
                    password_view_model.changed();
                });

                w = view;
            }

            var row_text = preferences_row as ViewModel.PreferencesRow.Text;
            if (row_text != null) {
                w = new Adw.ActionRow() {
                    title = row_text.title,
                    subtitle = row_text.text,
#if Adw_1_3
                    subtitle_selectable = true,
#endif
                };
                w.add_css_class("property");

                Util.force_css(w, "row.property > box.header > box.title > .title { font-weight: 400; font-size: 9pt; opacity: 0.55; }");
                Util.force_css(w, "row.property > box.header > box.title > .subtitle { font-size: inherit; opacity: 1; }");
            }

            var toggle_view_model = preferences_row as ViewModel.PreferencesRow.Toggle;
            if (toggle_view_model != null) {
                var view = new Adw.ActionRow() { title = toggle_view_model.title, subtitle = toggle_view_model.subtitle };
                var toggle = new Switch() { valign = Align.CENTER };
                view.activatable_widget = toggle;
                view.add_suffix(toggle);
                toggle_view_model.bind_property("state", toggle, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                w = view;
            }

            var combobox_view_model = preferences_row as ViewModel.PreferencesRow.ComboBox;
            if (combobox_view_model != null) {
                var string_list = new StringList(null);
                foreach (string text in combobox_view_model.items) {
                    string_list.append(text);
                }
#if Adw_1_4
                var view = new Adw.ComboRow() { title = combobox_view_model.title };
                view.model = string_list;
                combobox_view_model.bind_property("active-item", view, "selected", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
#else
                var view = new Adw.ActionRow() { title = combobox_view_model.title };
                var drop_down = new DropDown(string_list, null) { valign = Align.CENTER };
                combobox_view_model.bind_property("active-item", drop_down, "selected", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                view.activatable_widget = drop_down;
                view.add_suffix(drop_down);
#endif
                w = view;
            }

            var widget_view_model = preferences_row as ViewModel.PreferencesRow.WidgetDeprecated;
            if (widget_view_model != null) {
                var view = new Adw.ActionRow() { title = widget_view_model.title };
                view.add_suffix(widget_view_model.widget);
                w = view;
            }

            if (w == null) {
                continue;
            }

            preference_group.add(w);
        }

        return preference_group;
    }
}