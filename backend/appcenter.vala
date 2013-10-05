// valac --pkg=libsoup-2.4 --pkg=json-glib-1.0 appcenter.vala

using Soup;
using Json;

namespace AppCenter {
    
    public class AppInfo : GLib.Object {
        
        public string name;
        public string id;
        public string category;
        public string version;
        public string summary;
        public string description;
        public int64 rating;
        public string icon;
        public string price;
        public string author;
        public string website;
        public string license;
        public string[] screenshots;
        
        public AppInfo.from_json (Json.Object json) {
            this.name = json.get_string_member ("name");
            
            stdout.printf (name + "\n");
        }
    }
    
    public class DatabaseClient : GLib.Object {
    
        private const string HOST = "http://127.0.0.1";
        
        private const string APPS_BUCKET = "apps";
        private const string REVIEWS_BUCKET = "reviews";
        
        public static AppInfo? get_app_info (string id) {
            // Soup query
            var session = new Soup.SessionSync ();
            var message = new Soup.Message ("GET", HOST + ":8092/apps/_design/dev_apps/_view/apps?key=\"%s\"".printf(id));

            session.send_message (message);
            
            // JSON parsing
            try {
                var parser = new Json.Parser ();
                parser.load_from_data ((string) message.response_body.flatten ().data, -1);
                    
                var root_object = parser.get_root ().get_object ();
                
                foreach (var node in root_object.get_array_member ("rows").get_elements ()) {
                    var object = node.get_object ();
                    
                    var app_json = object.get_object_member ("value");
                    return new AppInfo.from_json (app_json);
                }
            } catch (Error e) { 
                warning (e.message);
                return null;
            }
            
            return null; 
        }
       
    }

}

void main () {
    AppCenter.DatabaseClient.get_app_info ("appcenter");
}
