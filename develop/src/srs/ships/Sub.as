
//-- Класс Sub

//<DG2J code_mark="n775:SI_BEG" >
//</DG2J>

	//-- упоминание о DrakonGen
	
//<DG2J code_mark="n6:ACTION" >
   /**
    * Этот текст сгенерирован программой DrakonGen
    * @author Erv
    */

//</DG2J>
 
	//-- package//-- imports
	
//<DG2J code_mark="n4:ACTION" >
package  srs.ships
{
	 
import flash.geom.Point;
import flash.utils.getTimer;
import flash.events.MouseEvent;
import srs.AI.Situation1x1;

import srs.*;
import srs.scenario.Store;
import srs.sounds.*;
import srs.utils.*;

//</DG2J>
 
	//-- class Sub
	
//<DG2J code_mark="n5:ACTION" >
   /**
    * ...
    * @author Erv
    */
public class Sub extends Ship {


//</DG2J>
 
	//-- переменные
	
//<DG2J code_mark="n7:ACTION" >
protected var torp_aps:Array = new Array(); 

//</DG2J>
 
	//-- Sub()
	
//<DG2J code_mark="n776:SH_BEG" >
public function Sub(_main:Main,_enemy:int) {
//</DG2J>
 
		//-- super(_main, _enemy);
		
//<DG2J code_mark="n12:ACTION" >
super(_main, _enemy);
		//-- по умолчанию шумность подлодки 0.5
		setNoisy(0.5);

//</DG2J>
 
		//-- добавляем ТА-I
		
//<DG2J code_mark="n13:ACTION" >
var ta:TorpedApp = new TorpedApp(this);
			torp_aps.push(ta);
			setTorpAppaForType(1, Constants.WEAPON_SELECT_TORP_I);

//</DG2J>
 
		//-- добавляем ТА-II
		
//<DG2J code_mark="n14:ACTION" >
var ta:TorpedApp = new TorpedApp(this);
			torp_aps.push(ta);
			setTorpAppaForType(2, Constants.WEAPON_SELECT_TORP_II);

//</DG2J>
 
		//-- добавляем ТА-III
		
//<DG2J code_mark="n15:ACTION" >
var ta:TorpedApp = new TorpedApp(this);
			torp_aps.push(ta);
			setTorpAppaForType(3, Constants.WEAPON_SELECT_TORP_III);

//</DG2J>
 
		//-- добавляем ТА-III
		
//<DG2J code_mark="n16:ACTION" >
var ta:TorpedApp = new TorpedApp(this);
			torp_aps.push(ta);
			setTorpAppaForType(4, Constants.WEAPON_SELECT_TORP_III);

//</DG2J>
 
		//-- //--         
		
//<DG2J code_mark="n763:SH_END" >
}
//</DG2J>

	//--  AI_step_I()
	
//<DG2J code_mark="n777:SH_BEG" >
override public function AI_step_I():void {
//</DG2J>
 
		//-- super.AI_step_I()
		
//<DG2J code_mark="n10:ACTION" >
super.AI_step_I();

//</DG2J>
 
		//-- //--         
		
//<DG2J code_mark="n764:SH_END" >
}
//</DG2J>

	//--  isTorpedReady()
	
//<DG2J code_mark="n778:SH_BEG" >
override protected function isTorpedReady():Boolean {
//</DG2J>
 
		//-- пока всегда true
		
//<DG2J code_mark="n51:ACTION" >
return true;
//</DG2J>
 
		//-- //--         
		
//<DG2J code_mark="n766:SH_END" >
}
//</DG2J>

	//-- Проверка готовности оружия weapon_type к стрельбе
	
//<DG2J code_mark="n779:SH_BEG" >
override public function isWeaponReady(weapon_type:int):TorpedApp {
//</DG2J>
 
		//-- возвр. пер
		
//<DG2J code_mark="n27:ACTION" >
var ret_ta:TorpedApp;
//</DG2J>
 
		//-- для каждого ТА
		
//<DG2J code_mark="n19:FOR_BEG" >
for each(var ta:TorpedApp in torp_aps) {
//</DG2J>

			//-- сообщение для выбранного готовность оружия
			
//<DG2J code_mark="n53:ACTION" >
if (display_selected) {
	Main.main.getInformer().writeDebugRightField("reload "+ta.getType().toFixed(0), ta.state.toFixed(0));
}

//</DG2J>
 
			//-- ТА нужного типа и готов?
			if(
//<DG2J code_mark="n21:IF" >
ta.getType() == weapon_type && ta.state == Constants.ST_TA_READY
//</DG2J>
) {
				//-- сообщение для выбранного готовность оружия
				
//<DG2J code_mark="n56:ACTION" >
if (display_selected) {
	Main.main.getInformer().writeDebugRightField("reload", "true");
}

//</DG2J>
 
				//-- возвр. ta
				
//<DG2J code_mark="n54:ACTION" >
ret_ta = ta;
//</DG2J>
 
			} else {
			}
		}
		//-- возвр. ТА
		
//<DG2J code_mark="n767:SH_END" >
return ret_ta;
}
//</DG2J>

	//--  AI_select_weapon()
	
//<DG2J code_mark="n780:SH_BEG" >
override protected function AI_select_weapon(_target:Ship):TorpedParams {
//</DG2J>
 
		//-- задаем переменные
		
//<DG2J code_mark="n59:ACTION" >
var torp_params:TorpedParams;
var dist_max_III:Number;

//</DG2J>
 
		//-- определяем дистанцию до цели
		
//<DG2J code_mark="n60:ACTION" >
var dist:Number = Point.distance(position_gm, _target.getPosition());
//</DG2J>
 
		//-- типа III есть?
		if(
//<DG2J code_mark="n83:IF" >
torp_on_board_III > 0
//</DG2J>
) {
			//-- рассчитываем дистанцию стрельбы для оружия III
			
//<DG2J code_mark="n61:ACTION" >
//dist_max_III = torp_params_III.max_time_life_sec * 1000. *  torp_params_III.max_velocity_hum * Settings.koef_v;
dist_max_III = torp_params_III.dist_execution;
//</DG2J>
 
			//-- для типа III далеко?
			if(
//<DG2J code_mark="n62:IF" >
dist > dist_max_III
//</DG2J>
) {
				//-- типа II есть?
				if(
//<DG2J code_mark="n84:IF" >
torp_on_board_II > 0
//</DG2J>
) {
					//-- сообщение для выбранного "Выбрано оружие II"
					
//<DG2J code_mark="n66:ACTION" >
if (display_selected) {
	Main.main.getInformer().writeDebugText("Выбрано оружие II");
}

//</DG2J>
 
					//-- текущие параметры - тип II
					
//<DG2J code_mark="n64:ACTION" >
torp_params = torp_params_II;
//</DG2J>
 
				} else {
				}
			} else {
				//-- сообщение для выбранного "Выбрано оружие III"
				
//<DG2J code_mark="n67:ACTION" >
if (display_selected) {
	Main.main.getInformer().writeDebugText("Выбрано оружие III");
}

//</DG2J>
 
				//-- текущие параметры - тип III
				
//<DG2J code_mark="n63:ACTION" >
torp_params = torp_params_III;
//</DG2J>
 
			}
		} else {
			//-- типа II есть?
			if(
//<DG2J code_mark="n792:IF" >
torp_on_board_II > 0
//</DG2J>
) {
				//-- сообщение для выбранного "Выбрано оружие II"
				
//<DG2J code_mark="n791:ACTION" >
if (display_selected) {
	Main.main.getInformer().writeDebugText("Выбрано оружие II");
}

//</DG2J>
 
				//-- текущие параметры - тип II
				
//<DG2J code_mark="n790:ACTION" >
torp_params = torp_params_II;
//</DG2J>
 
			} else {
			}
		}
		//-- возвр. выбранные параметры
		
//<DG2J code_mark="n768:SH_END" >
return torp_params;
}
//</DG2J>

	//-- Назначить аппарат ta_num под торпеду класса _torp_type
	
//<DG2J code_mark="n781:SH_BEG" >
public function setTorpAppaForType(ta_num:int, _torp_type:int):void {
//</DG2J>
 
		//-- ТА № назначить для типа ТИП
		
//<DG2J code_mark="n25:ACTION" >
torp_aps[ta_num-1].setType(_torp_type);
//</DG2J>
 
		//-- //--         
		
//<DG2J code_mark="n769:SH_END" >
}
//</DG2J>

	//-- на Медленной событие
	
//<DG2J code_mark="n782:SH_BEG" >
override public function onSlowLoop(time:int):void {
//</DG2J>
 
		//-- для каждого ТА
		
//<DG2J code_mark="n29:FOR_BEG" >
for each(var ta:TorpedApp in torp_aps) {
//</DG2J>

			//-- медленное событи ТА
			
//<DG2J code_mark="n31:ACTION" >
ta.onSlowLoop(time);
//</DG2J>
 
		}
		//-- //--         
		
//<DG2J code_mark="n770:SH_END" >
}
//</DG2J>

	//-- 
            
	
//<DG2J code_mark="n771:SI_END" >
   } //-- конец класса
} //-- крнец пакета
//</DG2J>
 
