import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
using StringTools;

class Build {
	public static function main() {
		var dir = ".";
		var files = FileSystem.readDirectory(dir);
		files.sort((a, b) -> a > b ? 1 : -1);
		
		var toc = new StringBuf();
		toc.add("### Table of contents\r\n");
		
		var rxSection = ~/^(\d+) (.+)\.md$/;
		var sections = [];
		
		function preproc(md) {
			md = ~/\[(.+?)\]\((?:!|#s|#spoiler)\)/g.map(md, (rx) -> {
				return "<details><summary>Spoiler</summary>"
					+ rx.matched(1).htmlEscape()
					+ "</details>";
			});
			return md;
		}
		
		for (rel in files) {
			if (rel == "README.md") continue;
			
			var full = Path.join([dir, rel]);
			if (FileSystem.isDirectory(full)) continue;
			
			if (Path.extension(rel).toLowerCase() != "md") continue;
			
			if (!rxSection.match(rel)) continue;
			
			var num = rxSection.matched(1);
			var title = rxSection.matched(2);
			
			var md = File.getContent(full).rtrim();
			md = preproc(md);
			if (num != "0") {
				toc.add("\r\n");
				if (!num.endsWith("0")) toc.add("\t");
				var id = title.toLowerCase();
				id = id.replace(" ", "-");
				id = ~/[^\w-]/.replace(id, "");
				toc.add('- [$title](#$id)');
				var a = '<a name="$id"/>';
				md = '# $a $title\r\n$md';
			}
			sections.push(md);
		}
		//
		sections[0] = "<!-- NB! README.md is generated from all other .md files, don't edit it directly -->\r\n" + sections[0];
		sections[0] += "\r\n\r\n" + toc.toString();
		var md = sections.join("\r\n\r\n");
		File.saveContent("README.md", md);
	}
}