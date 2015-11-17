var img_res = 4;
var sobel_config = {
	name: 'sobel_layout',
	toolbar:{
		name: 'sobel_toolbar',
    	items: [
        	{ type: 'check',  id: 'sobel_capture', caption: 'Start capture', icon: 'fa-camera-retro', checked: false },
        	{ type: 'break',  id: 'break0' },
			{ type: 'menu',   id: 'img_res', caption: 'Resolution', icon: 'fa-camera',  items: [
				{ text: '640x480', icon: 'fa-table' },
				{ text: '320x240', icon: 'fa-table'},
				{ text: '160x120', icon: 'fa-table'}
			]},
			{ type: 'button',  id: 'item7',  caption: 'Item 5', icon: 'fa-flag' }
        ],
		resolution:2,
        onClick: function (event) {
            
            switch(event.target)
			{
    			case 'sobel_capture':
    				//console.log('checked is'+event.item.checked);
    				 if(event.object.checked == false)
    				{
    					console.log("Starting capture");
    					$("#sobel_img").load(function() {
                            if (this.complete && typeof this.naturalWidth != "undefined" || this.naturalWidth != 0) {
                            	$("#sobel_img").attr("src", "/hsv?res="+img_res+"&fetch="+new Date().getTime());
                            }
                        });
                        $("#sobel_img").attr("src", "/hsv?res="+img_res+"&fetch="+new Date().getTime());
    				}
    				else
    				{
    					$("#sobel_img").unbind('load');
    				}
    				break;
    			default: //do nothing
    				console.log('Event: ' + event.type + ' Target: ' + event.target);
    				console.log(event);
			}
        }
	},
    panels: [
        { 	
        	type: 'top', 
        	size: 50, 
        	style: 'padding: 5px;', 
        	content: 'top'
        },
        { 
        	type: 'main', 
        	style: 'padding: 0px;', 
        	content:'<div style="padding: 10px"><p>Sobel image</p><img id="sobel_img" src="/hsv?res=4"/></div>' 
        }
    ]
}
$().w2toolbar(sobel_config.toolbar)
$().w2layout(sobel_config);
w2ui.sobel_layout.content('top',w2ui.sobel_toolbar);
w2ui.sobel_toolbar.on('*', function (event) {
	if(event.type == "click")
	{
		if(event.target == "img_res:640x480") img_res = 0;
		else if(event.target == "img_res:320x240") img_res = 4;
		else if(event.target == "img_res:160x120") img_res = 2;
	}	
//console.log('EVENT: '+ event.type + ' TARGET: '+ event.target, event);
});
