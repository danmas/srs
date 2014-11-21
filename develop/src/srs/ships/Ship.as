
//-- Класс Ship
//& 
	//-- упоминание о DrakonGen
	   /**
    * Этот текст сгенерирован программой DrakonGen
    * @author Erv
    */
 
	//-- package//-- imports
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
 
	//-- class Ship
	   /**
    * ...
    * @author Erv
    */
public class Ship extends Vehicle {

 
	//-- константы Маневр
		static protected const  MANEVR_UNKNOWN:int = 0;
	static protected const  MANEVR_STING:int = 1;
	static protected const  MANEVR_TORP_DEFENCE_MOVING:int = 2;
	static protected const  MANEVR_CONVOY_MOVING:int = 3;
	static protected const  MANEVR_TARGET_SEARCH_AGGRESSIVE:int = 4;
	static protected const  MANEVR_TARGET_SEARCH_RESERVED = 5;
	static protected const  MANEVR_RUNAWAY = 6;  //-- бегство
	static protected const  MANEVR_PANIC_RUNAWAY = 7;  //-- паническое бегство
	static protected const  MANEVR_ATTACK_AGGRESSIVE:int = 8; //-- атака агрессивая
	static protected const  MANEVR_ATTACK_SILENT = 9; //-- атака тихая
 
	//-- переменные
		//-- переменные
	protected var hit_count:int = 0;
		
	protected var size_for_hit:Number = Settings.SHIP_HIT_SIZE; //-- расстояние на котором торпеда попадает в этот корабль
		
	protected var time_reload_torped_ms:int = 15000;  //-- время загрузки торпеды (ДЛЯ БОТОВ!)
	protected var time_torp_fire:uint; //-- время выстрела торпедой
		
	protected var store:Store;
		
	protected var default_torp_app:TorpedApp;
	
	protected var health:Number = 1000.;
	protected var convoy:Boolean = false;
	protected var folow_convoy:Boolean = false;
	protected var folow_convoy_angle:Number = 90;
	protected var folow_convoy_dist:Number = 200;
	
	protected var cur_ship_target:Ship;
		
	protected var no_hit_damage:Boolean = false;
	//-- список мишеней
	protected var targets:Array = new Array();
		
	protected var param_before_atack:VehicleParams;
	protected var param_t_before_atack:VehicleParams;
	//-- признак уклонения от торпедных атак
	protected var anty_torp_manevr:Boolean = true;
	
	protected var situation:Situation1x1 = null;
	protected var prev_situation:Situation1x1 = null;
	//protected var situation_mem:String = "";
	
	protected var torp_params_I:TorpedParams;
	protected var torp_params_II:TorpedParams;
	protected var torp_params_III:TorpedParams;
	
	protected var torp_on_board_I:int = 5;
	protected var torp_on_board_II:int = 5;
	protected var torp_on_board_III:int = 5;
	
	protected var manevr_state:int = MANEVR_UNKNOWN;
	
	//-- true если объект выбран на дисплее
	protected var display_selected:Boolean = false;

	//-- роли судна
	protected var role_convoy_defender:Boolean = false; //-- охрана конвоя 
 
	//-- AI характер
	static protected const  AI_PEPPER_AGGRESSIVE :int = 1; //-- агрессивный
static protected const  AI_PEPPER_RESERVED   :int = 2; //-- скрытный, тихий
static protected const  AI_PEPPER_COWARD     :int = 3; //-- трусливый

protected var pepper_AI:int = AI_PEPPER_AGGRESSIVE; //-- характер
 
	//-- AI роли судна
	static protected const  AI_ROLE_TRANSPORT :int = 1; //-- транспорт
static protected const  AI_ROLE_CONVOY_DEFENDER :int = 2;  //-- охранение конвоя

private var role:int = AI_ROLE_CONVOY_DEFENDER; //-- охрана конвоя 
 
	//-- Ship()
	public function Ship(_main:Main,_enemy:int) { 
		//-- задаем ситуцию 1х1
		situation = new Situation1x1(this);
prev_situation = new Situation1x1(this); 
		//-- тело процедуры
				super(_main);
		setForces(_enemy);
		if (forces == Constants.FORCES_RED) {
			store = Main.getRedStore();
		} else {
			store = Main.getWhiteStore();
		}
		default_torp_app = new TorpedApp(this);
		
		this. addEventListener(MouseEvent.CLICK, selectOnDisplay); 
		this. addEventListener(MouseEvent.DOUBLE_CLICK, underControl); 
		//this. addEventListener(MouseEvent.CLICK, underControl); 
 
		//-- мы за белых?
		if(forces == Constants.FORCES_WHITE) {
			//-- получаем параметры оружия типа I,II и III
			torp_params_I = Main.getWhiteStore().getParams_I();
torp_params_II = Main.getWhiteStore().getParams_II();
torp_params_III = Main.getWhiteStore().getParams_III();
 
		} else {
			//-- получаем параметры оружия типа I,II и III
			torp_params_I = Main.getRedStore().getParams_I();
torp_params_II = Main.getRedStore().getParams_II();
torp_params_III = Main.getRedStore().getParams_III();
 
		}
		//-- //--             
		}
	//-- оценка ситуации
	override public function AI_step_I():void { 
		//-- Ручное управление?
		if(isUnderControl()) {
		} else {
			//--  заполняем список целей
			fillAllTarget(); 
			//-- оцениваем ситуацию
			situation.detectSituation(); 
			//-- ситуация изменилась?
			if(prev_situation.getCode() != situation.getCode()) {
				//-- сообщение для выбранного "Ситуация"
				showInfoMessageForSelected("Situation:  " + situation.getCode()); 
				//-- запоминиаем ситуацию
				prev_situation.copy(situation); 
				//-- Принятие решения//-- при изменении ситуации
				AI_on_change_situation(); 
			} else {
			}
			//-- Принятие решения//-- 
			AI_on_situation(); 
		}
		//-- //--             
		}
	//-- Принятие решения при изменении ситуации
	public function AI_on_change_situation():void {
//super.AI_step_II(); 
		//-- Угроза торпедной атаки?
		if(situation.situation == Settings.SIT_UNDER_TRP_ATTACK) {
			//-- Выполнялся противо торп маневр?
			if(manevr_state == MANEVR_TORP_DEFENCE_MOVING) {
			} else {
				//-- запоминаем прежний курс чтобы вернуться
				param_before_atack =  new VehicleParams(position_gm, velocity_gm, direction_deg); 
				//-- запоминаем параметры торпеды//-- чтобы потом двигаться в этом направлении
				param_t_before_atack =  new VehicleParams(situation.danger_torp.getPosition(), situation.danger_torp.getVelocity(), situation.danger_torp.getDirection()); 
				//-- убираем предыдущий маршрут
				stopMoveOnWayPoint(); 
				//-- Выполняем //-- противоторпедный маневр
				showInfoMessageForSelected("Выполняем противоторпедный маневр");
 
				//-- выполняем //-- противоторпедный маневр
				antyTorpManevr(situation.danger_torp); 
			}
			//-- маневр
			manevr_state = 
			//-- ПРОТИТОРПЕДНЫЙ
			MANEVR_TORP_DEFENCE_MOVING; 
		} else {
			//-- Выполнялся противо торп маневр?
			if(manevr_state == MANEVR_TORP_DEFENCE_MOVING) {
				//-- Конец противоторп.маневра.
				showInfoMessageForSelected("Конец противоторп.маневра.");
 
				//-- стираем МТ и перкращаем движение к ним
				stopMoveOnWayPoint();
 
				//-- устанавливаем запомненное направление
				setDirection(param_before_atack.direction); 
				//-- были команды?
				if(commands != null) {
					//-- Возвращаемся к движению по программе
					showInfoMessageForSelected("Возвращаемся к движению по программе."); 
					//-- продолжаем движение по командам
					//-- стираем запомненное состояние
					param_before_atack = null; 
				} else {
					//-- Возвращаемся на прежний курс
					showInfoMessageForSelected("Возвращаемся на прежний курс.");
 
				}
			} else {
			}
			//-- ситуация
			switch(situation.situation ) {
				//-- ОПРЕДЕЛЕНА ОШИБОЧНО
				case Settings.SIT_ERROR_DETEСTION:
					//-- маневр
					manevr_state = 
					//-- НЕ ОПРЕДЕЛЕН
					MANEVR_UNKNOWN; 
					//-- break
					break; 
				//-- ВРАГ ОБНАРУЖЕН
				case Settings.SIT_ENEMY_DETECTED:
					//-- Роль защитник конвоя?
					if(isRoleConvoyDefender()) {
						//-- характер агрессивный?
						if(pepper_AI == AI_PEPPER_AGGRESSIVE) {
							//-- маневр
							manevr_state = 
							//-- ПОИСК ВРАГА АГРЕСС
							MANEVR_TARGET_SEARCH_AGGRESSIVE; 
						} else {
							//-- характер скрытный?
							if(pepper_AI == AI_PEPPER_RESERVED) {
								//-- маневр
								manevr_state = 
								//-- ПОИСК ВРАГА ТИХИЙ
								MANEVR_TARGET_SEARCH_RESERVED; 
							} else {
								//-- маневр
								manevr_state = 
								//-- НЕ ОПРЕДЕЛЕН
								MANEVR_UNKNOWN; 
							}
						}
					} else {
						//-- характер трусливый?
						if(pepper_AI == AI_PEPPER_COWARD) {
							//-- маневр
							manevr_state = 
							//-- ТИХОЕ БЕГСТВО
							MANEVR_RUNAWAY; 
						} else {
							//-- маневр
							manevr_state = 
							//-- НЕ ОПРЕДЕЛЕН
							MANEVR_UNKNOWN; 
						}
					}
					//-- break
					break; 
				//-- ВРАГ НЕ ОБНАРУЖЕН
				case Settings.SIT_NOENEMY:
					//-- Роль защитник конвоя или нужно следовать в конвое?
					if(isRoleConvoyDefender() || isFolowConvoy()) {
						//-- выбираем конвоируемое судно
						var c:Ship = selectConvoy(); 
						//-- нашли подконвойного?
						if(c != null) {
							//-- были старые WP?
							if(way_points != null) {
								//-- стираем WP и перкращаем движение к ним 
								stopMoveOnWayPoint();
 
							} else {
							}
							//-- устанавливаем WP точку конвоя
							var p:Point = c.getPosition()		.add(Point.polar(folow_convoy_dist,folow_convoy_angle));
addWayPoint(p.x, p.y, Constants.WP_CONVOY);
 
							//-- двигаемся с максимальной скоростью
							setPower(POWER_6); 
							//-- начинаем движение к точке конвоя
							startMoveOnWP(); 
							//-- Производим конвоирование
							showInfoMessageForSelected("Производим конвоирование.");
 
							//-- маневр
							manevr_state = 
							//-- КОНВОИРОВАНИЕ
							MANEVR_CONVOY_MOVING; 
						} else {
							//-- Подконвойного не нашли
							showInfoMessageForSelected("Подконвойного не нашли.");
 
							//-- маневр
							manevr_state = 
							//-- НЕ ОПРЕДЕЛЕН
							MANEVR_UNKNOWN; 
						}
					} else {
						//-- маневр
						manevr_state = 
						//-- НЕ ОПРЕДЕЛЕН
						MANEVR_UNKNOWN; 
					}
					//-- break
					break; 
				//-- ВРАГ НА ДИСТ.ОГНЯ
				case Settings.SIT_ENEMY_ON_FIRE_DISTANCE:
					//-- Роль защитник конвоя?
					if(isRoleConvoyDefender()) {
						//-- характер агрессивный?
						if(pepper_AI == AI_PEPPER_AGGRESSIVE) {
							//-- маневр
							manevr_state = 
							//-- АТАКА АГРЕССИВНАЯ
							MANEVR_ATTACK_AGGRESSIVE; 
						} else {
							//-- характер скрытный или трусливый?
							if(pepper_AI == AI_PEPPER_RESERVED || pepper_AI == AI_PEPPER_COWARD) {
								//-- маневр
								manevr_state = 
								//-- АТАКА ТИХАЯ
								MANEVR_ATTACK_SILENT; 
							} else {
								//-- маневр
								manevr_state = 
								//-- НЕ ОПРЕДЕЛЕН
								MANEVR_UNKNOWN; 
							}
						}
					} else {
						//-- маневр
						manevr_state = 
						//-- БЕГСТВО
						MANEVR_RUNAWAY; 
						//-- характер
						switch(pepper_AI) {
							//-- ТРУСЛИВЫЙ
							case AI_PEPPER_COWARD:
								//-- маневр
								manevr_state = 
								//-- ПАНИЧЕСКОЕ БЕГСТВО
								MANEVR_PANIC_RUNAWAY; 
							//-- СКРЫТНЫЙ
							case AI_PEPPER_RESERVED:
								//-- маневр
								manevr_state = 
								//-- ТИХОЕ БЕГСТВО
								MANEVR_RUNAWAY; 
						}
					}
					//-- break
					break; 
				//-- ВРАГ РЯДОМ
				case Settings.SIT_ENEMY_CLOSE:
					//-- Роль защитник конвоя?
					if(isRoleConvoyDefender()) {
						//-- маневр
						manevr_state = 
						//-- АТАКА АГРЕССИВНАЯ
						MANEVR_ATTACK_AGGRESSIVE; 
					} else {
						//-- маневр
						manevr_state = 
						//-- ПАНИЧЕСКОЕ БЕГСТВО
						MANEVR_PANIC_RUNAWAY; 
					}
					//-- break
					break; 
			}
		}
		//-- //--             
		}
	//-- AI_on_situation()
	public function AI_on_situation():void { 
		//-- маневр
		switch(manevr_state) {
			//-- АТАКА АГРЕССИВНАЯ
			case MANEVR_ATTACK_AGGRESSIVE:
				//-- двигаемся с максимальной скоростью
				setPower(POWER_6); 
				//-- Двигаемся в противоположном направлении от цели
				//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg+180.);
 
				//-- Открываем огонь
				AI_torped_fire(); 
				//-- Агрессивная атака. Движемся на врага с максимальной скоростью и открываем огонь.
				showInfoMessageForSelected("Агрессивная атака. Движемся на врага с максимальной скоростью и открываем огонь.");
 
				//-- break
				break; 
			//-- ПАНИЧЕСКОЕ БЕГСТВО
			case MANEVR_PANIC_RUNAWAY:
				//-- двигаемся с максимальной скоростью
				setPower(POWER_6); 
				//-- Двигаемся в противоположном направлении от цели
				//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg+180.);
 
				//-- Паническое бегство. Удираем в противоположном направлении от врага.
				showInfoMessageForSelected("Паническое бегство. Удираем в противоположном направлении от врага.");
 
				//-- break
				break; 
			//-- АТАКА ТИХАЯ
			case MANEVR_ATTACK_SILENT:
				//-- двигаемся с максимально тихой скоростью не меньше 1
				var dist:Number = Point.distance(position_gm, situation.target.ship.getPosition());
var pow:int = POWER_6;
while(pow > POWER_1) {
	var ns:Number =  VehicleMoving.calcNoise(this.noisy, pow, dist);
	if (ns < Settings.NOISE_TRAKCING_RANGE) 
		break;
	pow--;	
}

setPower(pow);
 
				//-- Двигаемся в противоположном направлении от цели
				//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg+180.);
 
				//-- Открываем огонь
				AI_torped_fire(); 
				//-- Тихая атака. Подкрадываемся и атакуем.
				showInfoMessageForSelected("Тихая атака. Подкрадываемся и атакуем.");
 
				//-- break
				break; 
			//-- НЕ ОПРЕДЕЛЕН
			case MANEVR_UNKNOWN:
				//-- break
				break; 
			//-- ТИХОЕ БЕГСТВО
			case MANEVR_RUNAWAY:
				//-- двигаемся с максимально тихой скоростью не меньше 1
				var dist:Number = Point.distance(position_gm, situation.target.ship.getPosition());
var pow:int = POWER_6;
while(pow > POWER_1) {
	var ns:Number =  VehicleMoving.calcNoise(this.noisy, pow, dist);
	if (ns < Settings.NOISE_TRAKCING_RANGE) 
		break;
	pow--;	
}

setPower(pow);
 
				//-- Двигаемся в противоположном направлении от цели
				//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg+180.);
 
				//-- Тихое бегство. Тихо двигаемся в противоположном направлении от врага.
				showInfoMessageForSelected("Тихое бегство. Тихо двигаемся в противоположном направлении от врага.");
 
				//-- break
				break; 
			//-- ПОИСК ВРАГА ТИХИЙ
			case MANEVR_TARGET_SEARCH_RESERVED:
				//-- дистанция 
				if(situation.target.distance < torp_params_III.dist_execution * 0.2) {
					//-- устанавливаем WP на боковую точку
					var p:Point;
//-- в какую сторону поворачивать выбираем случайно
if(Math.random()>0.5)
	p = Point.polar(200., Utils.toScreenRad(direction_deg + 110)); 
else 
	p = Point.polar(100., Utils.toScreenRad(direction_deg - 110)); 
var p2:Point = position_gm.add(p);
addWayPoint(p2.x, p2.y, Constants.WP_TARGET);
 
				} else {
					//-- двигаемся с максимально тихой скоростью не меньше 1
					var dist:Number = Point.distance(position_gm, situation.target.ship.getPosition());
var pow:int = POWER_6;
while(pow > POWER_1) {
	var ns:Number =  VehicleMoving.calcNoise(this.noisy, pow, dist);
	if (ns < Settings.NOISE_TRAKCING_RANGE) 
		break;
	pow--;	
}

setPower(pow);
 
					//-- Двигаемся в предполагаемом направлении на цель
					//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg);
 
				}
				//-- Тихий поиск. Двигаемся в предполагаемом направлении на цель
				showInfoMessageForSelected("Тихий поиск. Двигаемся в предполагаемом направлении на цель." + angle_deg.toFixed(3));
 
				//-- break
				break; 
			//-- ПОИСК ВРАГА АГРЕСС
			case MANEVR_TARGET_SEARCH_AGGRESSIVE:
				//-- двигаемся с максимальной скоростью
				setPower(POWER_6); 
				//-- Двигаемся в предполагаемом направлении на цель
				//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg);
 
				//-- Агрес поиск. Двигаемся в предполагаемом направлении на цель
				showInfoMessageForSelected("Агрес поиск. Двигаемся в предполагаемом направлении на цель." + angle_deg.toFixed(3));
 
				//-- break
				break; 
		}
		//-- //--             
		}
	//-- Заполняет список мишеней
	public function fillAllTarget():void { 
		//-- Заполняет список мишеней//-- - чистим список мишеней
					//-- чистим список мишеней
			targets.splice(0);
			if (forces == Constants.FORCES_RED)
			{
				for each (var s:Ship in Main.main.getWhiteShips())
				{
					var dist:Number = Point.distance(position_gm, s.position_gm);
					//-- вычисляем шум цели
					var ns:Number = VehicleMoving.calcNoise(s.noisy, s.getPower(), dist);
					//main.getInformer().writeDebugRightField("my noise", ns.toFixed(3));
					//-- если разрешение по шуму > NOISE_TRAKCING_RANGE
					if (ns >= Settings.NOISE_TRAKCING_RANGE)
					{
						addTarget(s, ns);
					}
				}
			}
			else
			{
				for each (var s:Ship in Main.main.getRedShips())
				{
					dist = Point.distance(position_gm, s.position_gm);
					//-- вычисляем шум цели
					ns = VehicleMoving.calcNoise(s.noisy, s.getPower(), dist);
					//-- берем в обработку только превышающие порог NOISE_TRAKCING_RANGE
					if (ns >= Settings.NOISE_TRAKCING_RANGE)
					{
						addTarget(s, ns);
					}
				}
				main.getInformer().writeDebugRightField("detect", targets.length.toFixed(0));
			}
 
		//-- //--             
		}
	//-- (AI) Выбор цели 
	/**
			 * Выбор цели на которую начинаем охоту
			 * сейчас возвращается самая громкая
			 * 
			 * overrided для Ship и Torpedo 
			 */ 
			override public function selectTarget():Target { 
		//-- определяем перемнные
		var ret_trg:Target;
var ns:Number = 0; 
		//-- для всех целей
		for each(var trg:Target in targets) {
			//-- выбираем самую громкую цель
			if(ns == 0) {
	ns = trg.noise;	
	ret_trg = trg;
} else if (trg.noise > ns) {
	ret_trg = trg;
	ns = trg.noise;
} 
		}
		//-- возвр. цель
		return ret_trg;
}
	//-- Проверка наличия торпедной атаки
				/*
			 * Проверка наличия торпедной атаки
			 * 
			 * Проверяем для всех торпед и выбираем ближайшую.
			 * Возвращает атакующую торпеду.
			 */ 
			public function checkTrpAtack():Torped {
 
		//-- тело процедуры
						//-- выполняем проверку только для тех у кого установлен признак
				if (!anty_torp_manevr) {
					return null;
				}
				//-- для всех вражеских торпед определяем угол направления движения
				//   если меньше определенного то считаем что случилась угроза торпедной атаки
				//   для судна под управлением выводим сигнал
				if (forces == Constants.FORCES_RED) {
					for each( var t:Torped in main.getWhiteTorpeds()) {
						var dist:Number = Point.distance(t.getPosition(), position_gm); 
						if(dist < Settings.TRP_ATACK_DISTANCE_WARNING) {
							var angle:Number = Math.abs(Utils.calcDeltaBattleDeg(t.getPosition(), t.getDirection(), position_gm));
							var a:Number = Settings.TRP_ATACK__ANGLE_WARNING / Settings.TRP_ATACK_DISTANCE_WARNING * dist;
							if (angle < a ) {
								return t;
							}
						}
					}
				} else {
					for each(t in main.getRedTorpeds()) {
						dist = Point.distance(t.getPosition(), position_gm); 
						//main.getInformer().writeDebugRightField("trp at a", angle.toString());
						if(dist < Settings.TRP_ATACK_DISTANCE_WARNING) {
							angle = Math.abs(Utils.calcDeltaBattleDeg(t.getPosition(), t.getDirection(), position_gm));
							a = Settings.TRP_ATACK__ANGLE_WARNING / Settings.TRP_ATACK_DISTANCE_WARNING * dist;
							if (angle < a ) {
								if (under_control) {
									main.startTatcAlarm();
								}
								return t;
							}
						}
					}
					if (under_control) {
						main.stopTatcAlarm();
					}
				} 
		//-- возвр. угр торпеду
		return null;
}
	//-- (AI) Противоторпедный маневр
	protected function antyTorpManevr(t:Torped):void { 
		//-- определяем дистанцию до угрожающей Т
		var dist:Number = Point.distance(position_gm, t.getPosition()); 
		//-- торпеда далеко?
		if(dist > Settings.TRP_ATACK_ALARM_DIST) {
			//-- угол уклонения TRP_ATACK_DEFENSE_ANGLE
			var angle = Settings.TRP_ATACK_DEFENSE_ANGLE;
 
			//-- Неподвижен?
			if(getPower() == POWER_0) {
				//-- двигаемся с тихой скоростью
				setPower(POWER_1); 
			} else {
			}
		} else {
			//-- угол уклонения //-- 90
			var angle = 90;  
			//-- двигаемся с максимальной скоростью
			setPower(POWER_6); 
		}
		//-- стираем WP и перкращаем движение к ним 
		stopMoveOnWayPoint();
 
		//-- вырабатываем точку уклонения пока не выйдем из атаки//-- в какую сторону поворачивать выбираем случайно
		var p:Point;
//-- в какую сторону поворачивать выбираем случайно
if(Math.random()>0.5)
	p = Point.polar(100., Utils.toScreenRad(direction_deg + angle)); 
else 
	p = Point.polar(100., Utils.toScreenRad(direction_deg - angle)); 
var p2:Point = position_gm.add(p); 
		//-- устанавливаем WP на точку уклонения
		addWayPoint(p2.x, p2.y, Constants.WP_TORP_DEFENCE); 
		//-- начинаем движение к точке уклонения
		startMoveOnWP(); 
		//-- //--         
		}
	//--  Маневр УКОЛ
	/*
 * Маневр УКОЛ
 */ 
protected function manevrStick():void  {
 
		//-- тело процедуры
		//-- переопределить в дочерних классах 
		//-- //--         
		}
	//-- (AI) Выбор оружия
				/**
			 * Выбор оружия по параметрам цели и степени его готовности
			 */ 
			protected function AI_select_weapon(_target:Ship):TorpedParams {
 
		//-- задаем переменные
		var torp_params:TorpedParams;
var dist_max_III:Number;

 
		//-- определяем дистанцию до цели
		var dist:Number = Point.distance(position_gm, _target.getPosition()); 
		//-- рассчитываем дистанцию стрельбы для оружия III
		dist_max_III = torp_params_III.dist_execution;
//dist_max_III = torp_params_III.max_time_life_sec * 1000. *  torp_params_III.max_velocity_hum * Settings.koef_v;
 
		//-- для типа III далеко?
		if(dist > dist_max_III) {
			//-- сообщение для выбранного "Выбрано оружие I"
			if (display_selected) {
	Main.main.getInformer().writeDebugText("Выбрано оружие I");
}
 
			//-- текущие параметры - тип I
			torp_params = torp_params_I; 
		} else {
			//-- сообщение для выбранного "Выбрано оружие III"
			if (display_selected) {
	Main.main.getInformer().writeDebugText("Выбрано оружие III");
}
 
			//-- текущие параметры - тип III
			torp_params = torp_params_III; 
		}
		//-- возвр. выбранные параметры
		return torp_params;
}
	//-- исполнение
	public function AI_step_III():void  { 
		//-- строим код
		/*var ret_code:String = "";
ret_code += enemy.getName();
ret_code += " "+situation;
ret_code += " "+enemy_ship_type;
ret_code += " "+enemy_dist_change;
*/ 
		//-- //--             
		}
	//-- AI_torped_fire()
				/**
			 * 
			 * Выбор торпеды
			 * Рассчет точки выстрела для прямолинейно движущихся торпед.
			 * Можно улучшить алгоритм повысив точность за счет второго цикла итераций
			 * 
			 */
			public function AI_torped_fire():void {
 
		//-- локальные переменные
		var _getMaxTimeLifeSec:Number;		
var _getMaxVelocity:Number;
var _getWeaponType:int;
var fire_state: int = 0; 
var cur_torp_app:TorpedApp; 
		//-- торпеды перезаряжены?
		if(isTorpedReady()) {
			//-- цель есть?
			if(situation.target != null) {
				//-- корабль цели  есть?
				if(situation.target.ship != null) {
					//-- время запуска
					var start_time:int =  
					//-- getTimer()
					getTimer(); 
					//-- выбираем оружие для цели
					var torp_params:TorpedParams =  AI_select_weapon(situation.target.ship);
 
					//-- Выбор сделан?
					if(torp_params != null) {
						//-- узнаем тип оружия
						_getWeaponType = torp_params.weapon_type; 
						//-- оружие типа I?
						if(_getWeaponType == Constants.WEAPON_SELECT_TORP_I) {
							//-- текущий аппарат оружия типа I
							cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_I); 
						} else {
							//-- оружие типа II?
							if(_getWeaponType == Constants.WEAPON_SELECT_TORP_II) {
								//-- текущий аппарат оружия типа II
								cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_II); 
							} else {
								//-- оружие типа III?
								if(_getWeaponType == Constants.WEAPON_SELECT_TORP_III) {
									//-- текущий аппарат оружия типа III
									cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_III); 
								} else {
									//-- текущий аппарат оружия не выбран
									cur_torp_app = null; 
								}
							}
						}
						//-- текущий аппарат готов?
						if(cur_torp_app != null) {
							//-- берем максимальную скорость и время жизни для выбранного оружия
							_getMaxTimeLifeSec = torp_params.max_time_life_sec;
		_getMaxVelocity = torp_params.max_velocity_hum; 
							//-- вспомогательные переменные
							var target_position:Point;
var len:Number; 
var torpedo_position:Point;
var target_position2:Point;
var t_ms:Number = 0; 

var vp:VehicleParams = new VehicleParams(situation.target.ship.position_gm
	,situation.target.ship.velocity_gm
	,situation.target.ship.direction_deg); 
target_position2 = situation.target.ship.position_gm;
 
							//-- вычисляем dt //-- = время жизни / AI_torped_fire_interva
							var dt:Number = _getMaxTimeLifeSec * 1000. / Settings.AI_torped_fire_interval; // * 5.;
; 
							//-- интегация 
							for(var i:int = 1; i < Settings.AI_torped_fire_interval; i++) {
								//-- t_ms += dt;
								t_ms += dt; 
								//-- время жизни вышло?
								if(t_ms > _getMaxTimeLifeSec * 1000) {
									//-- return
									return; 
								} else {
								}
								//-- рассчитываем положение цели в момент времени dt ПРЯМОЛИНЕЙНЫЙ АЛГОРИТМ
								var p:Point = Point.polar(t_ms * situation.target.ship.getVelocity()
   , Utils.toScreenRad(situation.target.ship.getDirection()));
target_position = situation.target.ship.getPosition().add(p);
 
								//-- рассчитываем положение цели в момент времени t. УЧИТЫВАЕТСЯ ТЕКУЩИЙ МАНЕВР ЦЕЛИ
								vp = VehicleMoving.move_calc_pos2(dt, vp, situation.target.ship.getCommandParams()
	, situation.target.ship.max_velocity_hum,	situation.target.ship.manevr_prc);
target_position2 = vp.position;
 
								//-- Рисовать расчет?
								if(Settings.DRAW_TORPED_CALC) {
									//-- рисуем точки вчтречи по линейному алгоритму и по второму
									var c:CustomCircle = new CustomCircle(target_position.x, target_position.y, 2, 0xffff00);
c.x = main.toDisplayX(c.getX());
c.y = main.toDisplayX(c.getY());
main.addChild(c);

var c2:CustomCircle = new CustomCircle(target_position2.x, target_position2.y, 2, 0xff00ff);
c2.x = main.toDisplayX(c2.getX());
c2.y = main.toDisplayX(c2.getY());
main.addChild(c2);
 
								} else {
								}
								//-- рассчитываем расстояни которое пройдет торпеда и расстояние от нас до цели 
								//-- за время t торпеда пройдет 
len = t_ms * _getMaxVelocity * Settings.koef_v ; 
//-- рассчитываем расстояние от нашей позиции до target.ship_position
var dist:Number = Point.distance(this.position_gm, target_position2);
 
								//-- Торпеда дойдет до цели?
								if(len > dist) {
									//-- вычисляем точку встречи//-- и направление выстрела
									var atak_point:Point = target_position2.subtract(position_gm);
var angle:Number = Utils.calcAngle(0, 0, atak_point.x, atak_point.y);
var torp:Torped; 
									//-- Я подлодка?
									if(this is Sub) {
										//-- Выбранное оружие торпеда II?
										if(_getWeaponType == Constants.WEAPON_SELECT_TORP_II) {
											//-- Пуск торпеды II в расчетную точку 
											showInfoMessageForSelected("Пуск торпеды II в расчетную точку ."+target_position2.x.toFixed(0));
 
											//-- выстрел в рассчитанную //-- позицию
											torp = fireAtPosition(_getWeaponType, 	target_position2); 
										} else {
											//-- Пуск торпеды I,II в направлении движения
											showInfoMessageForSelected("Пуск торпеды I,II в направлении движения.");
 
											//-- выстрел в //-- направлении движения
											torp = fire_in_direction(_getWeaponType,getDirection());
//main.fire_in_direction(this, Utils.toBattleDegree(angle), _getWeaponType);
//cur_torp_app.onFire(); 
										}
										//-- выстрел произошел?
										if(torp != null) {
										} else {
											//-- return
											return; 
										}
										//-- регистрация торпеды,//-- торпедный аппарат выстрелил
										main.registerTorped(torp,getForces());
cur_torp_app.onFire();
 
									} else {
										//-- Пуск торпеды I,II в направлении движения
										showInfoMessageForSelected("Пуск торпеды I,II в направлении движения.");
 
										//-- выстрел в направлении расч.точки,торпедный аппарат выстрелил
										main.fire_in_direction(this, Utils.toBattleDegree(angle), _getWeaponType);
cur_torp_app.onFire();
 
									}
									//-- если нужно, рисуем точки вчтречи по линейному алгоритму и по второму
									if(Settings.DRAW_TORPED_CALC) {
var p1:Point = Point.polar(dist, angle);
var p2:Point = p1.add(position_gm);
c2 = new CustomCircle(p2.x, p2.y, 3, 0xFF6347);
c2.x = main.toDisplayX(c2.getX());
c2.y = main.toDisplayX(c2.getY());
main.addChild(c2);
} 
									//-- перываем расчёт
									break; 
								} else {
								}
							}
							//-- увеличиваем время потраченное на работу AI
							Statistic.AI_calc_time += getTimer() - start_time;
 
						} else {
						}
					} else {
					}
				} else {
				}
			} else {
			}
		} else {
		}
		//-- //--             
		}
	//-- fire_in_direction()
	public function fire_in_direction(_weapon_select:int, dir_deg:Number):Torped {
 
		//-- тело процедуры
		if (forces == Constants.FORCES_RED) {
	Statistic.enemy_fire_count++;
	var s:SoundEnemyTorpFire = new SoundEnemyTorpFire();
	s.play(0.3);
} else {
	var s2:SoundMyTorpFire = new SoundMyTorpFire();
	s2.play(0.7);
	Statistic.friend_fire_count++;
}
time_torp_fire = getTimer();
var torp:Torped;
if (_weapon_select == Constants.WEAPON_SELECT_TORP_I) {
	torp = new Torped_I(main, forces);
	torp_on_board_I--;
} else if (_weapon_select == Constants.WEAPON_SELECT_TORP_II) {
	torp = new Torped_II(main, forces);
	torp_on_board_II--;
} else if (_weapon_select == Constants.WEAPON_SELECT_TORP_III) {
	torp = new Torped_III(main, forces);
	torp_on_board_III--;
}
torp.setForces(this.forces);
torp.setPosition2(getPosition());
torp.setDirection(dir_deg);
torp.set_velocity(torp.getMaxVelocityHum() * Settings.koef_v); // velocity);
//torp.setName("my torped");
torp.start_move();
//main.registerEnemyTorped(torp);
 
		//-- возвр. торпеду
		return torp;
}
	//-- выход
		//-- isWeaponReady()
		/**
		 * Проверка готовности оружия weapon_type к стрельбе
		 *
		 * @param	weapon_type - тип оружия
		 * @return    TorpedApp - готовый к стрельбе
		 *
		 * @overrided  Sub
		 */
		public function isWeaponReady(weapon_type:int):TorpedApp
		{
			if (!Settings.CHEAT)
				if ((getTimer() - time_torp_fire) > time_reload_torped_ms)
					return default_torp_app;
			return null;
		} 
		//-- calcNoiseAtDist()
				/**
		 * Рассчитывет шум данного сугна на расстоянии dist
		 *
		 * @param	dist
		 * @return
		 */
		public function calcNoiseAtDist(dist:Number):Number
		{
			return VehicleMoving.calcNoise(noisy, getPower(), dist);
		} 
		//-- selectConvoy()
		/**
		 * Выбор судна конвоя
		 *
		 * overrided для Ship
		 */
		public function selectConvoy():Ship
		{
			//-- для того который под ручным управление не выбираем цель
			if (under_control)
			{
				return null;
			}
			////-- пока исходим из того, что я один ))
			if (forces == Constants.FORCES_RED)
			{
				for each (var s:Ship in Main.main.getRedShips())
				{
					if (s.isConvoy())
					{
						return s;
					}
				}
			}
			else
			{
				for each (var s:Ship in Main.main.getWhiteShips())
				{
					if (s.isConvoy())
					{
						return s;
					}
				}
			}
			return null;
		} 
		//-- onSlowLoop()//-- getStore()
		/**
		 * Обработка события редкого цикла
		 *
		 * @param	time
		 *
		 * overrides in Sub
		 */
		public function onSlowLoop(time:int):void
		{
		}
		
		/**
		 *
		 */
		public function getStore():Store
		{
			return store;
		} 
		//-- getTorpOnBoard()
		public function getTorpOnBoard(wt:int):int {
	switch(wt) {
		case Constants.WEAPON_SELECT_TORP_I:
			return torp_on_board_I;
		case Constants.WEAPON_SELECT_TORP_II:
			return torp_on_board_II;
		case Constants.WEAPON_SELECT_TORP_III:
			return torp_on_board_III;
	}
	return 0;
}
 
		//-- hasHit()
		public function hasHit(damage:Number):void
		{
			hit_count++;
			//trace(hit_count);
			
			var snd:SoundExplosion = new SoundExplosion();
			snd.play(1.);
			if (under_control)
			{
				var snd2:SoundAlarm = new SoundAlarm();
				snd2.play(1.);
			}
			
			if (forces == Constants.FORCES_RED)
			{
				Statistic.enemy_hit_count++;
			}
			else
			{
				Statistic.friend_hit_count++;
			}
			if (!no_hit_damage)
			{
				setMaxVelocityHum(getMaxVelocityHum() / Settings.HIT_SHIP_SPEED_DECREASE);
				time_reload_torped_ms *= Settings.HIT_TIME_RELOAD_INCREASE;
				var nn:Number = time_reload_torped_ms / 1000.
				//if(enemy==NOTENEMY)
				//	main.getInformer().setField("FL0", nn.toFixed(0));
				//else
				//	main.getInformer().setField("FL1", nn.toFixed(0));
				health -= damage;
				Main.main.getInformer().writeDebugRightField("damg", health.toFixed(0));
				//if (hit_count >= max_hits) {
				if (health <= 0)
				{
					trace("I'm die! (" + ship_name + ")");
					main.getInformer().setCommandAlarm("I'm die! (" + ship_name + ")");
					destroy();
					if (forces == Constants.FORCES_RED)
						Statistic.enemy_destroyed++;
					else
						Statistic.friend_destroyed++;
				}
			}
		
		} 
		//-- isTorpedReady()
		protected function isTorpedReady():Boolean {
 
		//-- просто проверяем прошло ли положенное время с момента последнего выстрела
		return (getTimer() - time_torp_fire) > 
		time_reload_torped_ms  + Math.random() * time_reload_torped_ms/2.;
		//-- выход
		
		
	} 
		//-- setAggressivePepper()//-- setReservedPepper()
		public function setAggressivePepper() {
	pepper_AI = AI_PEPPER_AGGRESSIVE;
}
public function setReservedPepper() {
	pepper_AI = AI_PEPPER_RESERVED;
}
public function setCowardPepper() {
	pepper_AI = AI_PEPPER_COWARD;
}
 
		//-- fireAtPosition()
		public function fireAtPosition(_weapon_select:int, _way_point:Point):Torped
{
	var torp:Torped = fire_in_direction(_weapon_select,getDirection());
	if (torp == null)
		return null;
	torp.addWayPoint(_way_point.x, _way_point.y, Constants.WP_TORP);
	torp.startMoveOnWayPoint(); //.startMoveOnWayPoint( /*Constants.WP_TORP*/);
	torp.setPower(Vehicle.POWER_6);
	return torp;
}
 
		//-- drawTargets()
		/**
		 * Рисует мишени как они видятся с данного судна
		 */
		public function drawTargets():void
		{
			for each (var trg:Target in targets)
			{
				trg.ship.setVisible(true);
				
				if (trg.noise >= Settings.NOISE_DETECTION)
				{
					if (trg.ship.getForces() == Constants.FORCES_RED)
						trg.ship.color = Constants.COLOR_LIGHT_RED;
					else
						trg.ship.color = Constants.COLOR_LIGHT_WHITE;
				}
				else if (trg.noise >= Settings.NOISE_DIRECTION)
				{
					if (trg.ship.getForces() == Constants.FORCES_RED)
						trg.ship.color = Constants.COLOR_MADIUM_RED;
					else
						trg.ship.color = Constants.COLOR_MADIUM_WHITE;
					trg.ship.setTailVisible(true);
					trg.ship.info.visible = true;
					if (trg.ship is Sub)
						trg.ship.info.text = "SUB";
					else
						trg.ship.info.text = "SHIP";
				}
				else
				{
					if (trg.ship.getForces() == Constants.FORCES_RED)
						trg.ship.color = Constants.COLOR_DARK_RED;
					else
						trg.ship.color = Constants.COLOR_DARK_RED;
					trg.ship.visible = true;
					trg.ship.setTailVisible(false);
					trg.ship.info.visible = false;
				}
				trg.ship.new_disp_pos();
				trg.ship.draw_ship();
			}
		} 
		//-- draw_ship_sub()
		protected function draw_ship_sub():void
		{
			var bh:Number = 14;
			var bw:Number = 3;
			var sh:Number = bw / 2.;
			
			var rh:Number = 3.;
			var rw:Number = 1.;
			
			var shift_x:Number = -bw / 2.;
			var shift_y:Number = -(bh + (bw + bw + bw - sh)) / 2.;
			
			//graphics.beginFill(0xffffff);
			//graphics.lineStyle(1, 0xffffff);
			graphics.beginFill(color);
			graphics.lineStyle(1, color);
			graphics.drawRoundRect(0 + shift_x, 0 + shift_y, bw, bh, bw, bw);
			
			graphics.moveTo(0 + shift_x, bh - sh + shift_y);
			graphics.lineTo(bw / 2. + shift_x, bh + bw + bw + bw - sh + shift_y);
			graphics.lineTo(bw + shift_x, bh - sh + shift_y);
			graphics.moveTo(0 + shift_x, bh - sh + shift_y);
			graphics.endFill();
			
			graphics.lineStyle(1, 0x0f0f0f);
			graphics.beginFill(0x0f0f0f);
			graphics.drawEllipse(bw / 2. - rw / 2. + shift_x, bh * 1 / 3. - rh / 2. + shift_y, rw, rh);
			graphics.endFill();
		} 
		//-- draw_ship()//-- draw_ship_0()
		override protected function draw_ship():void
		{
			//graphics.clear();
			draw_ship_0();
		}
		
		protected function draw_ship_0():void
		{
			if (under_control && this is Sub)
			{
				draw_ship_sub();
			}
			else
			{
				graphics.lineStyle(2, color);
				graphics.moveTo(-4, 4);
				graphics.lineTo(-4, -4);
				graphics.lineTo(4, -4);
				graphics.lineTo(4, 4);
				//graphics.moveTo( -4, 4);
				graphics.endFill();
				
				graphics.beginFill(0x0000FF, 0.5);
				graphics.drawRect(-4, -4, 8, 8);
				graphics.endFill();
			}
		} 
		//-- draw_ship_selected()
		override protected function draw_ship_selected():void
		{
			//if (Settings.DEBUG) {
			//-- круги шумности
			var dist_00:Number = VehicleMoving.calcNoiseDistanse(noisy, getPower(), .2);
			graphics.lineStyle(2, Constants.COLOR_DARK_RED);
			graphics.drawCircle(0, 0, dist_00 * main.getZoom());
			
			dist_00 = VehicleMoving.calcNoiseDistanse(noisy, getPower(), .5);
			graphics.lineStyle(2, Constants.COLOR_MADIUM_RED);
			graphics.drawCircle(0, 0, dist_00 * main.getZoom());
			
			dist_00 = VehicleMoving.calcNoiseDistanse(noisy, getPower(), .8);
			graphics.lineStyle(2, Constants.COLOR_LIGHT_RED);
			graphics.drawCircle(0, 0, dist_00 * main.getZoom());
			//}
			
			draw_ship_0();
			//x = main.toDisplayX(position_gm.x);
			//y = main.toDisplayY(position_gm.y);
		} 
		//-- drawShip()
		override public function drawShip():void
		{
			var idx:int = main.getChildIndex(this);
			if (idx < 0)
				return;
			graphics.clear();
			if (display_selected)
			{
				draw_ship_selected();
			}
			else
			{
				draw_ship();
			}
		} 
		//-- infoText()
		override public function infoText():void
		{
			var vel:Number = velocity_gm / Settings.koef_v;
			var s1:Ship = main.getMyShip();
			if (!under_control)
			{
				if (s1 != null)
				{
					info.text = ship_name + "(" + health.toFixed(0) + ")" // "x=" + this.x.toFixed(0) + " y=" + this.y.toFixed(0) + "\n" 
						+ "\n" + Point.distance(s1.position_gm, this.position_gm).toFixed(0) + "," + Utils.toBattleDegree(Utils.calcAngleRad(s1.position_gm, position_gm)).toFixed(0) 
						//+ "\n" + position.x.toFixed(0) + " " + position.y.toFixed(0)	
						+ "\n" + vel.toFixed(0);
				}
				else
				{
					info.text = ship_name // "x=" + this.x.toFixed(0) + " y=" + this.y.toFixed(0) + "\n" 
						+ "\n" + vel.toFixed(0);
				}
			}
			else
			{
				info.text = ship_name 
					//+ "\n" + position.x.toFixed(0) + "," + position.y.toFixed(0)
					+ "\n" + command_params.power // Point.distance(main.getScenario().getStartPosition(), position).toFixed(0) 
					+ "," + direction_deg.toFixed(0) 
					//+ "\n" + x + "," + y
					+ "\n" + vel.toFixed(0);
			}
		
		} 
		//-- getResolvStr()
				/**
		 * Возвращает строкой насколько данный корабль видит указанный
		 *
		 * @param	res_ship
		 */
		public function getResolvStr(res_ship:Ship):String
		{
			for each (var trg:Target in targets)
			{
				if (trg.ship == res_ship)
				{
					return "" + trg.noise.toFixed(3);
				}
			}
			return "0";
		}
 
		//-- setDispalySelected()
		public function setDispalySelected(ds:Boolean) {
display_selected = ds;
}
	
 
		//-- showTarget()//-- showInfoMessageForSelected()
				//-- 
		//--       showTarget()
		//--       
		/**
		 * Выводит информацию о текущей цели на правую панель
		 */
		public function showTarget():void {
		if (targets.length == 0) {
			main.getInformer().setCommand("No target defined, Sir.");
			return;
		}
								var trg:Target;
								if (cur_ship_target != null) {
			for each (trg in targets) {
				if (trg.ship == cur_ship_target) {
					break;
				}
			}
		}
		if (trg == null) 	{
			trg = targets[0];
			cur_ship_target = trg.ship;
		}
		main.getInformer().writeRightField("tgt name", cur_ship_target.getName());
		main.getInformer().writeRightField("tgt noise", trg.noise.toFixed(3));
		main.getInformer().writeRightField("tgt resolv", cur_ship_target.getResolvStr(this));
		}
		
		/*
		 * Выводит сообщение если судно выбрано на дисплее
		 */ 
		public function showInfoMessageForSelected(msg:String):void {		
			if (display_selected) {
				var s:String = this.getName() + ": " + msg;
				Main.main.getInformer().writeText(s);
				trace(s);
			}
		}
 
		//-- selectOnDisplay()
		/**
		 * Обработка клика мышки
		 *
		 * @param	event
		 */
		public function selectOnDisplay(event:MouseEvent):void
		{
			//trace(event.currentTarget.toString() + " dispatches MouseEvent. Local coords [" + 
			//event.localX + "," + event.localY + "] Stage coords [" + event.stageX + "," + event.stageY + "]"); 
			
			if (display_selected)
				display_selected = false;
			else
				display_selected = true;
			drawShip();
		} 
		//-- underControl()
		/**
		 * Делает текущим управляемым объектом данный корабль
		 */
		public function underControl(event:MouseEvent):void
		{
			main.getMyShip().setUnderControl(false);
			main.getMyShip().drawShip();
			this.setUnderControl(true);
			main.setMyShip(this);
			main.getMyShip().drawShip();
		} 
		//-- setTimeReloadTorped()//-- getTimeReloadTorpSec()
				public function setTimeReloadTorped(t_sec:Number):void
		{
			time_reload_torped_ms = t_sec * 1000;
		}
		
		public function getTimeReloadTorpSec():Number
		{
			return time_reload_torped_ms / 1000;
		}
 
		//-- setRoleConvoyDefender()//-- isRoleConvoyDefender()
		/*
 * Установка признака того, что корабль ораняет конвой
 */
public function setRoleConvoyDefender():void {
	role = AI_ROLE_CONVOY_DEFENDER;
}

/*
 * Получение признака того, что корабль ораняет конвой
 */
public function isRoleConvoyDefender():Boolean {
	return role == AI_ROLE_CONVOY_DEFENDER;
}

/*
 * Получение признака того, что корабль следует за конвоем
 */
public function isFolowConvoy():Boolean {
	return folow_convoy;
}

/*
 * Установка признака того, что корабль является транспортом
 */
public function setRoleTransport():void {
	role = AI_ROLE_TRANSPORT;
}

/*
 * Получение признака того, что корабль ораняет конвой
 */
public function isRoleTransport():Boolean {
	return role == AI_ROLE_TRANSPORT;
}
 
		//-- setConvoy()//-- isConvoy()
		public function setConvoy(_convoy:Boolean):void
		{
			convoy = _convoy;
		}
		
		public function isConvoy():Boolean
		{
			return convoy;
		} 
		//-- setFollowConvoy()
		/**
		 * Следовать за конвоем на отдалении angle, dist
		 *
		 * @param	folow_convoy_dist
		 * @param	folow_convoy_angle
		 */
		public function setFollowConvoy(_folow_convoy_dist:Number, _folow_convoy_angle:Number):void
		{
			folow_convoy = true; // folow_convoy;
			folow_convoy_angle = _folow_convoy_angle;
			folow_convoy_dist = _folow_convoy_dist;
		} 
		//-- setAntyTorpManevr()
		public function setAntyTorpManevr(_anty_torp_manevr:Boolean):void {
	anty_torp_manevr = _anty_torp_manevr;
}
 
		//-- addTarget()
		protected function addTarget(_ship:Ship, _noise:Number):void
		{
			var trg:Target;
			for each (trg in targets)
			{
				if (trg.ship == _ship)
				{
					trg.noise = _noise;
					return;
				}
			}
			trg = new Target(_ship, _noise);
			targets.push(trg);
		} 
		//-- get/set SizeForHit
		/*
		 * Размер для попадания торпеды
		 */
		public function setSizeForHit(_torpedo_hit_distance:Number):void
		{
			size_for_hit = _torpedo_hit_distance;
		}
		
		public function getSizeForHit():Number
		{
			return size_for_hit;
}
		 
		//-- get/set Health//-- set NoHitDamage
		public function getHealth():Number
		{
			return health;
		}

public function setHealth(value:Number):void
		{
			health = value;
		}

public function setNoHitDamage(_no_hit_damage:Boolean):void
		{
			no_hit_damage = _no_hit_damage;
		}

public function setColor(_color:int):void
		{
			color = _color;
		} 
		//-- конец
		//}
	//-- 
            
	   } //-- конец класса
} //-- крнец пакета 
