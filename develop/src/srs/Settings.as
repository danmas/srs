package srs 
{
	import srs.utils.*;
	
	/**
	 * ...
	 * @author Erv
	 */
	public class Settings 
	{
		public static const CURRENT_PROGRAM:String = "Silent Red Storm"; 
		public static const CURRENT_VERSION:String = "v.07.0";
		public static const CURRENT_SRS:String = CURRENT_PROGRAM + " " + CURRENT_VERSION;
		//public static const CURRENT_SCENARIO:String = "Scenario1"; 
		//public static const CURRENT_SCENARIO:String = "Scenario1x1"; 
		public static const CURRENT_SCENARIO:String = "Scenario4"; 
		//public static const CURRENT_SCENARIO:String = "ScenarioTest"; 
		//public static const CURRENT_SCENARIO:String = "Scenario4MULT"; 
		//public static const CURRENT_SCENARIO:String = "Scenario3AI"; 
		
		public static const SCENARIO_SCORE_NAME:String = CURRENT_SCENARIO; 
		
		public static const DEBUG:Boolean = true;
		//public static const DEBUG:Boolean = false;
		
		//public static const DRAW_REAL_WORLD:Boolean = true;
		
		//-- отображать вражеские суда всегда если true
		public static const DRAW_REAL_WORLD:Boolean = true;
		
		//public static const CHEAT:Boolean = true;
		public static const CHEAT:Boolean = false;
		
		//public static const DRAW_TORPED_CALC:Boolean = true; //-- рисовать вычисления стрельбы торпедами
		public static const DRAW_TORPED_CALC:Boolean = false; //-- рисовать вычисления стрельбы торпедами
		
		/**/
		public static const SCALE_MAIN:Number = 1.5;  //-- Увеличение изображения экрана
		
		//-- Дельта рассогласования курса(в градусах) при движении на WP. 
		//   Если отклонение меньше дельты то направление не корректируется 
		public static const DELTA_COURSE_ON_WP:Number = 0.1;

		
		//-- физика
		public static const koef_v:Number = 0.0004;   //-- коефициент пересчета скорости физической в дисплейную Vdisp = Vphis * koef_v
		public static const alfa_v:Number = 0.0005;   //-- инерция изменения скорости
		public static const alfa_r_0:Number = 0.8;    //-- коефициент изменения угла поворота от положения руля и скорости
		public static const alfa_r_30:Number = 0.15;  //-- коефициент изменения угла поворота от положения руля и скорости
	
		//-- торпеды
		public static const HIT_TIME_RELOAD_INCREASE :Number = 1.3;  //-- коеф-т - время на которое увеличивается время заряжания после попадания
		public static const HIT_SHIP_SPEED_DECREASE :Number = 1.3;  //-- коеф-т - насколько уменьшается скорость при попадании торпеды
		
		public static const SHIP_HIT_SIZE:Number = 10;  //-- дистанция взрыва торпеды

		public static const TRP_I_LIFE_TIME_SEC:Number = 60;     //-- время жизни торпеды в сек
		public static const TRP_I_MAX_VELOCITY:Number = 60.; //-- максимальная скорость торпеды
		public static const TRP_I_MANEVR_PRC:Number = 80; //-- Маневренность в процентах
		public static const TRP_I_TIME_RELOAD_SEC:Number = 4;     //-- время загрузки торпеды в сек
		public static const TRP_I_DAMEGE:Number = 1000.;     //-- разрушение наносимое торпедой
		public static const TRP_I_DIST_EXECUTION:Number = 1000.;     //-- дистанция применения
		
		public static const TRP_II_LIFE_TIME_SEC:Number = 60;     //-- время жизни торпеды в сек
		public static const TRP_II_MAX_VELOCITY:Number = 50.; //-- максимальная скорость торпеды
		public static const TRP_II_MANEVR_PRC:Number = 100; //-- Маневренность в процентах
		public static const TRP_II_TIME_RELOAD_SEC:Number = 120;     //-- время загрузки торпеды в сек
		public static const TRP_II_DAMEGE:Number = 800.;     //-- разрушение наносимое торпедой
		public static const TRP_II_DIST_EXECUTION:Number = 1000.;     //-- дистанция применения

		public static const TRP_III_LIFE_TIME_SEC:Number = 30;     //-- время жизни торпеды в сек
		public static const TRP_III_MAX_VELOCITY:Number = 38.; //-- максимальная скорость торпеды
		public static const TRP_III_TRG_ACCEPT_DIST:Number = 200.; //-- Радиус самонаведения
		public static const TRP_III_MANEVR_PRC:Number = 100; //-- Маневренность в процентах
		public static const TRP_III_TIME_RELOAD_SEC:Number = 200;     //-- время загрузки торпеды в сек
		public static const TRP_III_DAMEGE:Number = 500.;     //-- разрушение наносимое торпедой
		public static const TRP_III_DIST_EXECUTION:Number = 300.;     //-- дистанция применения

		public static const koef_coast:Number = 15;        //-- масштаб карты порта. чем меньше, тем труднее выйти из него 
		
		public static const TAIL_MAX_LENGTH:int = 10;      //-- количество "булек" за кораблем или торпедой
		public static const TAIL_TIME_INTERVAL:int = 1000; //-- рисовать точку хвоста каждую TAIL_TIME_INTERVAL millisecs 
		public static const TAIL_COLOR:uint = 0x00ffff;    //-- цвет кильватерного следа
		
		public static const MOVE_INTERVAL_MS:int = 50;   //-- интервал движения
		public static const SLOW_LOOP_INTERVAL_MS:int = 1500;   //-- интервал медленных событий(интерфейсных)
		
		//-- AI. НЕ ТРОГАЙ БЕЗ НУЖДЫ!!!
		//-- число интерполяций рассчета движения цели
		public static const AI_torped_fire_interval:int = 100; 
		//-- дэльта т(в милисек) для предсказания движения цели 
		//public static const AI_TF_IMMITATION_DELTA_T_MS:int = 50; // 100; 
		
		public static var WEB_ENABLE:Boolean = true; //-- определяеи возможность/невозможность работы через интернет

		public static const TRP_ATACK__ANGLE_WARNING:Number = 25.; //-- угол направления торпеды в 0 при котором детектируется угроза атаки
		public static const TRP_ATACK_DISTANCE_WARNING:Number = 500.; //-- расстояние до торпеды в угле ANGLE_TRP_ATACK_WARNING при котором детектируется угроза атаки
		public static const TRP_ATACK_DEFENSE_ANGLE:Number = 45.; //-- угол маневра ухода от торпеды
		public static const TRP_ATACK_ALARM_DIST:Number = 300.; //-- расстояние до торпеды после которого нужно срочно уклоняться на максимальной скорости
		
		// удалить
		public static const MOVE_ON_TARGET_FROM_DIST:Number = 1000; //-- расстояние с котрого начинается охота за целью
		
		//public static const NOISE_UNDETECTABLE:Number = 0.2;
		public static const NOISE_TRAKCING_RANGE:Number = 0.2;  //-- с этого уровня начинается слежение за целью
		public static const NOISE_DIRECTION:Number = 0.5;  //-- с этого уровня начинает определяться направление и скорость цели
		public static const NOISE_DETECTION:Number = 0.8;
		
		
		//-- константы
		public static var SIT_UNKNOWN:String = "SIT_UNKNOWN"; 
		public static var SIT_ERROR_DETEСTION:String = "SIT_ERROR_DETEСTION"; 
		public static var SIT_NOENEMY:String = "SIT_NOENEMY";
		public static var SIT_ENEMY_HERE:String = "SIT_ENEMY_HERE"; //-- > 0.1
		public static var SIT_ENEMY_DETECTED:String = "SIT_ENEMY_DETECTED";  //-- > 0.2
		public static var SIT_ENEMY_ON_FIRE_DISTANCE:String = "SIT_ENEMY_ON_FIRE_DISTANCE"; //-- > 0.5
		public static var SIT_ENEMY_CLOSE:String = "SIT_ENEMY_CLOSE"; //-- > 0.8
		public static var SIT_UNDER_TRP_ATTACK:String = "SIT_UNDER_TRP_ATTACK"; //-- > 0.8
		
		public static var EST_UNKNOWN:String = "UNKNOWN";
		public static var EST_SUB:String = "SUB";
		public static var EST_SHIP:String = "SHIP";
		
		//-- distance change
		public static var DC_UNKNOWN:String = "DC_UNKNOWN";
		public static var DC_NOT_CHANGE:String = "DC_NOT_CHANGE";
		public static var DC_INCREASE:String = "DC_INCREASE";
		public static var DC_DECREASE:String = "DC_DECREASE";
		
	}

}