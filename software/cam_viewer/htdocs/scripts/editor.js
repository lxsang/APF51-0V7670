var html = '<div id="editor" style="position: absolute;top: 0;right: 0;bottom: 0;left: 0;"> \n'
		+'function foo(items) { \n'
        +' var x = "All this is syntax highlighted";\n'
    	+' return x;} \n'
    	+'</div> \n'
    	+'<script>\n'
    	+ 'ace.require("ace/ext/language_tools");'
    	+'var editor = ace.edit("editor");\n'
		+ 'editor.setOptions({'
    	+ 'enableBasicAutocompletion: true,'
    	+ 'enableSnippets: true,\n'
    	+ 'enableLiveAutocompletion: true \n'
		+ '});'
    	+'editor.setTheme("ace/theme/textmate");\n'
   	 	+'editor.getSession().setMode("ace/mode/javascript");\n'
		+'</script>';
var make_result = 	"plugin_manager.c:477: query :cmd=get-records&limit=100&offset=0<br>"
					+"plugin_manager.c:472: Client 4<br>"
					+"plugin_manager.c:473: Path : 'pluginsman'<br>"
					+"plugin_manager.c:474: Method:GET<br>"
					+"plugin_manager.c:475: Plugin name 'pluginsman'<br>"
					+"plugin_manager.c:476: Plugin func. 'execute'<br>"
					+"plugin_manager.c:477: query :cmd=get-records&limit=100&offset=0<br>"
					+"plugin_manager.c:472: Client 4<br>"
					+"plugin_manager.c:473: Path : 'pluginsman'<br>"
					+"plugin_manager.c:474: Method:GET<br>"
					+"plugin_manager.c:475: Plugin name 'pluginsman'<br>"
					+"plugin_manager.c:476: Plugin func. 'execute'<br>"
					+"plugin_manager.c:477: query :cmd=get-records&limit=100&offset=0<br>"
					+"plugin_manager.c:472: Client 4<br>";

var editor_layout = {
	layout:{
		name:'editor_layout',
		panels:[
			{
				type:'main',
				style: 'padding: 0px;', 
            	content: ''
            	
			},
			{
				type:'right',
				size:200,
				resizable:true,
				style: 'padding: 0px;', 
				content:'File Explorer'
			}
		]  
	},
	main_layout:{
		name:'editor_main_layout',
		panels:[
			{
				type:'main',
				style: 'padding: 0px;',
				content:html,
                tabs:{
                	active:'tab1',
                	tabs:[
                		{ id: 'tab1', caption: 'Test1.js' },
			            { id: 'tab2', caption: 'Test2.js', closable: true },
			            { id: 'tab3', caption: 'Test3.js', closable: true },
			            
                	],
                	onClick: function (event) {
                        this.owner.content('main', html);
                    }
                }
			},
			{
				type:'bottom',
				size:150,
				resizable: true,
				style: 'padding: 10px;background-color:white;', 
				content:make_result,
				toolbar: {
                    items: [
                        { type: 'check',  id: 'item1', caption: 'Check', img: 'icon-page', checked: true },
                        { type: 'break',  id: 'break0' },
                        { type: 'menu',   id: 'item2', caption: 'Drop Down', img: 'icon-folder', items: [
                            { text: 'Item 1', icon: 'icon-page' }, 
                            { text: 'Item 2', icon: 'icon-page' }, 
                            { text: 'Item 3', value: 'Item Three', icon: 'icon-page' }
                        ]},
                        { type: 'break', id: 'break1' },
                        { type: 'radio',  id: 'item3',  group: '1', caption: 'Radio 1', img: 'icon-page', hint: 'Hint for item 3', checked: true },
                        { type: 'radio',  id: 'item4',  group: '1', caption: 'Radio 2', img: 'icon-page', hint: 'Hint for item 4' },
                        { type: 'spacer' },
                        { type: 'button',  id: 'item5',  caption: 'Item 5', icon: 'w2ui-icon-check', hint: 'Hint for item 5' }
                    ],
                    onClick: function (event) {
                        //this.owner.content('main', event);
                    }
                }
			}
		]
	},
	right_layout:{
		name:'editor_right_layout',
		panels:[
			{
				type:'main',
				style: 'padding: 0px;',
				content:''
			},
			{
				type:'bottom',
				size:10,
				style: 'padding: 0px;', 
				content:'toolbar'
			}
		]
	},
	right_side_bar: {
        name: 'editor_right',
        nodes: [ 
            { id: 'level-ws', text: 'Workspace', img: 'icon-folder', expanded: true, group: true,
              nodes: [ { id: 'level-2-1', text: 'Project 1', img: 'icon-folder', count: 2,
                        nodes: [
                           { id: 'level-2-1-1', text: 'congfig.h.c', icon: 'fa-file' },
                           { id: 'level-2-1-2', text: 'plugin.c', icon: 'fa-file'}
                       ]},
                       { id: 'level-2-2', text: 'README.md', icon: 'fa-file' },
                       { id: 'level-2-3', text: 'Makefile', icon: 'fa-file' }
                     ]
            }
        ]
    },
    right_side_toolbar:{
        name: 'editor_right_toolbar',
        items: [
            { type: 'menu',   id: 'ed_tb_add', caption: 'New', icon: 'fa-plus',  
            items: [
                { text: 'New file', icon: 'fa-plus'}, 
                { text: 'New folder', icon: 'fa-plus'}
            ]}
        ]
    }

}
$().w2layout(editor_layout.right_layout);
$().w2sidebar(editor_layout.right_side_bar);
$().w2layout(editor_layout.main_layout);
$().w2layout(editor_layout.layout);
$().w2toolbar(editor_layout.right_side_toolbar);
w2ui.editor_right_layout.content('main', w2ui.editor_right);
w2ui.editor_right_layout.content('bottom', w2ui.editor_right_toolbar);
w2ui.editor_layout.content('main', w2ui.editor_main_layout);
w2ui.editor_layout.content('right', w2ui.editor_right_layout);

//w2ui.editor_layout.content('main',html);
w2ui.editor_layout.on('render', function(event) {
    console.log(w2ui.editor_layout.html('main'));
});
//var editor_body = $("<div></div>");
//w2ui.editor_layout.content('main',editor_body);
//
