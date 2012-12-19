typedef K = flash.ui.Keyboard;

@:bitmap("res/texture.gif")
class Tex extends flash.display.BitmapData {
}

@:file("res/model.fbx")
class Model extends flash.utils.ByteArray {
	
}

class Axis implements h3d.IDrawable {

	public function new() {
	}
	
	public function render( engine : h3d.Engine ) {
		engine.line(0, 0, 0, 50, 0, 0, 0xFFFF0000);
		engine.line(0, 0, 0, 0, 50, 0, 0xFF00FF00);
		engine.line(0, 0, 0, 0, 0, 50, 0xFF0000FF);
	}
	
}

class LightShader extends hxsl.Shader {
	static var SRC = {
		var input : {
			pos : Float3,
			norm : Float3,
			uv : Float2,
			weights : Float3,
			index : Int,
		};
		var shade : Float;
		var tuv : Float2;

		function vertex( mpos : Matrix, mproj : Matrix, light : Float3, bones : M34<39> ) {
			var p : Float4;
			p.xyz = pos.xyzw * weights.x * bones[index.x * (255 * 3)] + pos.xyzw * weights.y * bones[index.y * (255 * 3)] + pos.xyzw * weights.z * bones[index.z * (255 * 3)];
			p.w = 1;
			out = (p * mpos) * mproj;
			shade = (norm.xyzw * mpos).xyz.dot(light).sat() * 0.8 + 0.6;
			tuv = uv;
		}
		
		function fragment( tex : Texture ) {
			var color = tex.get(tuv,nearest);
			kill(color.a - 0.001);
			color.rgb *= shade;
			out = color;
		}
	}
}

class Anim {

	var engine : h3d.Engine;
	var scene : h3d.scene.Scene;

	var time : Float;
	var anim : h3d.prim.Animation;
	
	var flag : Bool;
	var view : Int;

	function new() {
		time = 0;
		view = 4;
		engine = new h3d.Engine();
		engine.backgroundColor = 0xFF808080;
		engine.onReady = onReady;
		engine.init();
	}
	
	function onReady() {
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, function(_) onUpdate());
		flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, function(k:flash.events.KeyboardEvent ) {
			var c = k.keyCode;
			if( c == K.NUMPAD_ADD )
				view++;
			else if( c == K.NUMPAD_SUBTRACT )
				view--;
			else if( c == K.SPACE )
				flag = !flag;
		});

		var tex = engine.mem.makeTexture(new Tex(0, 0));
		var file = new Model();
		var lib = new h3d.fbx.Library();
		lib.loadTextFile(file.readUTFBytes(file.length));
		
		scene = lib.makeScene(function(_) return tex);
		scene.camera.rightHanded = true;

		anim = lib.loadAnimation().createInstance(scene);
		
		scene.addPass(new Axis());
	}
	
	function onUpdate() {
		if( !engine.begin() )
			return;
			
		var dist = 50., height = 10.;
		var camera = scene.camera;
		switch( view ) {
		case 0:
			camera.pos.set(0, 0, dist);
			camera.up.set(0, 1, 0);
			camera.target.set(0, 0, 0);
		case 1:
			camera.pos.set(0, dist, height);
			camera.up.set(0, 0, 1);
			camera.target.set(0, 0, height);
		case 2:
			var K = Math.sqrt(2);
			camera.pos.set(dist, 0, height);
			camera.up.set(0, 0, 1);
			camera.target.set(0, 0, height);
		case 3:
			var K = Math.sqrt(2);
			camera.pos.set(dist, dist, height);
			camera.up.set(0, 0, 1);
			camera.target.set(0, 0, height);
		case 4:
			var speed = 0.02;
			camera.pos.set(Math.cos(time * speed) * dist, Math.sin(time * speed) * dist, height);
			camera.up.set(0, 0, 1);
			camera.target.set(0, 0, height);
		default:
			view = 0;
		}
		
		time += 1;
		anim.update(time * 0.5);
		
		engine.render(scene);
	}
	
	static function main() {
		new Anim();
	}

}