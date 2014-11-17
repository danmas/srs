
//-- Класс Sub

	
	//-- упоминание о DrakonGen
	   /**
	    * Этот текст сгенерирован программой DrakonGen
	    * @author Erv
	    */
	
	//-- package
	//-- imports
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
	
	//-- class Sub
	   /**
	    * ...
	    * @author Erv
	    */
	public class Sub extends Ship {
	
	
	//-- переменные
	protected var torp_aps:Array = new Array(); 
	
	//-- Sub()
		public function Sub(_main:Main,_enemy:int) { 
		//-- super(_main, _enemy);
		super(_main, _enemy);
		//-- по умолчанию шумность подлодки 0.5
		setNoisy(0.5);
		//-- добавляем ТА-I
		var ta:TorpedApp = new TorpedApp(this);
					torp_aps.push(ta);
					setTorpAppaForType(1, Constants.WEAPON_SELECT_TORP_I);
		
		//-- добавляем ТА-II
		var ta:TorpedApp = new TorpedApp(this);
					torp_aps.push(ta);
					setTorpAppaForType(2, Constants.WEAPON_SELECT_TORP_II);
		
		//-- добавляем ТА-III
		var ta:TorpedApp = new TorpedApp(this);
					torp_aps.push(ta);
					setTorpAppaForType(3, Constants.WEAPON_SELECT_TORP_III);
		
		//-- добавляем ТА-III
		var ta:TorpedApp = new TorpedApp(this);
					torp_aps.push(ta);
					setTorpAppaForType(4, Constants.WEAPON_SELECT_TORP_III);
		
		//-- выход
		
		
	} //-- конец процедуры
	//-- AI_step_I()
				/**
			 * Выбор направления движения
			 * 
			 * Здесь задается состояние движения
			 * 
			 * приоритет - уклонение от торпедной атаки
			 */ 
			override public function AI_step_I():void {
 
		//-- super.AI_step_I()
		super.AI_step_I();
		
		//-- выход
	} //-- конец процедуры
	//-- isTorpedReady()
	/*
			 */ 
			override protected function isTorpedReady():Boolean {
 
		//-- пока всегда true
		return true;
		//-- выход
		
		
	} //-- конец процедуры
	//-- Проверка готовности оружия weapon_type к стрельбе
	override public function isWeaponReady(weapon_type:int):TorpedApp { 
		//-- возвр. пер
		var ret_ta:TorpedApp;
		//-- для каждого ТА
		for each(var ta:TorpedApp in torp_aps)  {
			//-- 
			//--       сообщение для выбранного готовность оружия
			//--       
			if (display_selected) {
				Main.main.getInformer().writeDebugRightField("reload "+ta.getType().toFixed(0), ta.state.toFixed(0));
			}
			
			//-- ТА нужного типа и готов?
			if(ta.getType() == weapon_type && ta.state == Constants.ST_TA_READY) {
				//-- 
				//--       сообщение для выбранного готовность оружия
				//--       
				if (display_selected) {
					Main.main.getInformer().writeDebugRightField("reload", "true");
				}
				
				//-- возвр. ta
				ret_ta = ta;
			} else {
			}
		}
		//-- возвр. ТА
		return ret_ta;
	} //-- конец процедуры
	//-- AI_select_weapon()
				/**
			 * Выбор оружия по параметрам цели и степени его готовности
			 */ 
			override protected function AI_select_weapon(_target:Ship):TorpedParams {
 
		//-- задаем переменные
		var torp_params:TorpedParams;
		var dist_max_III:Number;
		
		//-- определяем дистанцию до цели
		var dist:Number = Point.distance(position_gm, _target.getPosition());
		//-- типа III есть?
		if(torp_on_board_III > 0) {
			//-- рассчитываем дистанцию стрельбы для оружия III
			//dist_max_III = torp_params_III.max_time_life_sec * 1000. *  torp_params_III.max_velocity_hum * Settings.koef_v;
			dist_max_III = torp_params_III.dist_execution;
			//-- для типа III далеко?
			if(dist > dist_max_III) {
				//-- типа II есть?
				if(torp_on_board_II > 0) {
					//-- 
					//--       сообщение для выбранного "Выбрано оружие II"
					//--       
					if (display_selected) {
						Main.main.getInformer().writeDebugText("Выбрано оружие II");
					}
					
					//-- текущие параметры - тип II
					torp_params = torp_params_II;
				} else {
				}
				//-- возвр. выбранные параметры
				return torp_params;
			} else {
				//-- 
				//--       сообщение для выбранного "Выбрано оружие III"
				//--       
				if (display_selected) {
					Main.main.getInformer().writeDebugText("Выбрано оружие III");
				}
				
				//-- текущие параметры - тип III
				torp_params = torp_params_III;
			}
			//-- возвр. выбранные параметры
			return torp_params;
		} else {
			//-- типа II есть?
			if(torp_on_board_II > 0) {
				//-- 
				//--       сообщение для выбранного "Выбрано оружие II"
				//--       
				if (display_selected) {
					Main.main.getInformer().writeDebugText("Выбрано оружие II");
				}
				
				//-- текущие параметры - тип II
				torp_params = torp_params_II;
			} else {
			}
			//-- возвр. выбранные параметры
			return torp_params;
		}
//-- ПРЕДУПРЕЖДЕНИЕ!   Терминатор развилки "типа III есть?" имеет 0 выходов. Должен быть один. 
	} //-- конец процедуры
	//-- Назначить аппарат ta_num под торпеду класса _torp_type
	public function setTorpAppaForType(ta_num:int, _torp_type:int):void { 
		//-- ТА № назначить для типа ТИП
		torp_aps[ta_num-1].setType(_torp_type);
		//-- выход
	} //-- конец процедуры
	//-- на Медленной событие
	override public function onSlowLoop(time:int):void { 
		//-- для каждого ТА
		for each(var ta:TorpedApp in torp_aps)  {
			//-- медленное событи ТА
			ta.onSlowLoop(time);
		}
		//-- выход
	} //-- конец процедуры
	//-- выход
		//-- конец
		   } //-- конец класса
		} //-- крнец пакета
