
//-- Класс Ship

//<DG2J code_mark="n798:SI_BEG" >
// 
//</DG2J>

	//-- упоминание о DrakonGen
	
//<DG2J code_mark="n616:ACTION" >
   /**
    * Этот текст сгенерирован программой DrakonGen
    * @author Erv
    */

//</DG2J>
 
	//-- package//-- imports
	
//<DG2J code_mark="n615:ACTION" >
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
 
	//-- class Ship
	
//<DG2J code_mark="n614:ACTION" >
   /**
    * ...
    * @author Erv
    */
public class Ship extends Vehicle {


//</DG2J>
 
	//-- константы Маневр
	
//<DG2J code_mark="n458:ACTION" >
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

//</DG2J>
 
	//-- переменные
	
//<DG2J code_mark="n459:ACTION" >
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

//</DG2J>
 
	//-- AI характер
	
//<DG2J code_mark="n460:ACTION" >
static protected const  AI_PEPPER_AGGRESSIVE :int = 1; //-- агрессивный
static protected const  AI_PEPPER_RESERVED   :int = 2; //-- скрытный, тихий
static protected const  AI_PEPPER_COWARD     :int = 3; //-- трусливый

protected var pepper_AI:int = AI_PEPPER_AGGRESSIVE; //-- характер

//</DG2J>
 
	//-- AI роли судна
	
//<DG2J code_mark="n478:ACTION" >
static protected const  AI_ROLE_TRANSPORT :int = 1; //-- транспорт
static protected const  AI_ROLE_CONVOY_DEFENDER :int = 2;  //-- охранение конвоя

private var role:int = AI_ROLE_CONVOY_DEFENDER; //-- охрана конвоя 

//</DG2J>
 
	//-- Ship()
	
//<DG2J code_mark="n799:SH_BEG" >
public function Ship(_main:Main,_enemy:int) {
//</DG2J>
 
		//-- задаем ситуцию 1х1
		
//<DG2J code_mark="n421:ACTION" >
situation = new Situation1x1(this);
prev_situation = new Situation1x1(this);
//</DG2J>
 
		//-- тело процедуры
		
//<DG2J code_mark="n613:ACTION" >
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

//</DG2J>
 
		//-- мы за белых?
		if(
//<DG2J code_mark="n610:IF" >
forces == Constants.FORCES_WHITE
//</DG2J>
) {
			//-- получаем параметры оружия типа I,II и III
			
//<DG2J code_mark="n612:ACTION" >
torp_params_I = Main.getWhiteStore().getParams_I();
torp_params_II = Main.getWhiteStore().getParams_II();
torp_params_III = Main.getWhiteStore().getParams_III();

//</DG2J>
 
		} else {
			//-- получаем параметры оружия типа I,II и III
			
//<DG2J code_mark="n611:ACTION" >
torp_params_I = Main.getRedStore().getParams_I();
torp_params_II = Main.getRedStore().getParams_II();
torp_params_III = Main.getRedStore().getParams_III();

//</DG2J>
 
		}
		//-- //--             
		
//<DG2J code_mark="n304:SH_END" >
}
//</DG2J>

	//-- оценка ситуации
	
//<DG2J code_mark="n189:SH_BEG" >
override public function AI_step_I():void {
//</DG2J>
 
		//-- Ручное управление?
		if(
//<DG2J code_mark="n456:IF" >
isUnderControl()
//</DG2J>
) {
		} else {
			//--  заполняем список целей
			
//<DG2J code_mark="n208:ACTION" >
fillAllTarget();
//</DG2J>
 
			//-- оцениваем ситуацию
			
//<DG2J code_mark="n298:ACTION" >
situation.detectSituation();
//</DG2J>
 
			//-- ситуация изменилась?
			if(
//<DG2J code_mark="n300:IF" >
prev_situation.getCode() != situation.getCode()
//</DG2J>
) {
				//-- сообщение для выбранного "Ситуация"
				
//<DG2J code_mark="n299:ACTION" >
showInfoMessageForSelected("Situation:  " + situation.getCode());
//</DG2J>
 
				//-- запоминиаем ситуацию
				
//<DG2J code_mark="n301:ACTION" >
prev_situation.copy(situation);
//</DG2J>
 
				//-- Принятие решения//-- при изменении ситуации
				
//<DG2J code_mark="n420:ACTION" >
AI_on_change_situation();
//</DG2J>
 
			} else {
			}
			//-- Принятие решения//-- 
			
//<DG2J code_mark="n455:ACTION" >
AI_on_situation();
//</DG2J>
 
		}
		//-- //--             
		
//<DG2J code_mark="n293:SH_END" >
}
//</DG2J>

	//-- Принятие решения при изменении ситуации
	
//<DG2J code_mark="n365:SH_BEG" >
public function AI_on_change_situation():void {
//super.AI_step_II();
//</DG2J>
 
		//-- Угроза торпедной атаки?
		if(
//<DG2J code_mark="n370:IF" >
situation.situation == Settings.SIT_UNDER_TRP_ATTACK
//</DG2J>
) {
			//-- Выполнялся противо торп маневр?
			if(
//<DG2J code_mark="n372:IF" >
manevr_state == MANEVR_TORP_DEFENCE_MOVING
//</DG2J>
) {
			} else {
				//-- запоминаем прежний курс чтобы вернуться
				
//<DG2J code_mark="n606:ACTION" >
param_before_atack =  new VehicleParams(position_gm, velocity_gm, direction_deg);
//</DG2J>
 
				//-- запоминаем параметры торпеды//-- чтобы потом двигаться в этом направлении
				
//<DG2J code_mark="n607:ACTION" >
param_t_before_atack =  new VehicleParams(situation.danger_torp.getPosition(), situation.danger_torp.getVelocity(), situation.danger_torp.getDirection());
//</DG2J>
 
				//-- убираем предыдущий маршрут
				
//<DG2J code_mark="n608:ACTION" >
stopMoveOnWayPoint();
//</DG2J>
 
				//-- Выполняем //-- противоторпедный маневр
				
//<DG2J code_mark="n385:ACTION" >
showInfoMessageForSelected("Выполняем противоторпедный маневр");

//</DG2J>
 
				//-- выполняем //-- противоторпедный маневр
				
//<DG2J code_mark="n377:ACTION" >
antyTorpManevr(situation.danger_torp);
//</DG2J>
 
			}
			//-- маневр
			
//<DG2J code_mark="n375:ACTION" >
manevr_state =
//</DG2J>
 
			//-- ПРОТИТОРПЕДНЫЙ
			
//<DG2J code_mark="n374:ACTION" >
MANEVR_TORP_DEFENCE_MOVING;
//</DG2J>
 
		} else {
			//-- Выполнялся противо торп маневр?
			if(
//<DG2J code_mark="n378:IF" >
manevr_state == MANEVR_TORP_DEFENCE_MOVING
//</DG2J>
) {
				//-- Конец противоторп.маневра.
				
//<DG2J code_mark="n387:ACTION" >
showInfoMessageForSelected("Конец противоторп.маневра.");

//</DG2J>
 
				//-- стираем МТ и перкращаем движение к ним
				
//<DG2J code_mark="n368:ACTION" >
stopMoveOnWayPoint();

//</DG2J>
 
				//-- устанавливаем запомненное направление
				
//<DG2J code_mark="n605:ACTION" >
setDirection(param_before_atack.direction);
//</DG2J>
 
				//-- были команды?
				if(
//<DG2J code_mark="n609:IF" >
commands != null
//</DG2J>
) {
					//-- Возвращаемся к движению по программе
					
//<DG2J code_mark="n386:ACTION" >
showInfoMessageForSelected("Возвращаемся к движению по программе.");
//</DG2J>
 
					//-- продолжаем движение по командам
					
//<DG2J code_mark="n602:ACTION" >
null
//</DG2J>
 
					//-- стираем запомненное состояние
					
//<DG2J code_mark="n604:ACTION" >
param_before_atack = null;
//</DG2J>
 
				} else {
					//-- Возвращаемся на прежний курс
					
//<DG2J code_mark="n389:ACTION" >
showInfoMessageForSelected("Возвращаемся на прежний курс.");

//</DG2J>
 
				}
			} else {
			}
			//-- ситуация
			switch(
//<DG2J code_mark="n391:SWITCH" >
situation.situation 
//</DG2J>
) {
				//-- ОПРЕДЕЛЕНА ОШИБОЧНО
				case 
//<DG2J code_mark="n392:CASE" >
Settings.SIT_ERROR_DETEСTION
//</DG2J>
:
					//-- маневр
					
//<DG2J code_mark="n413:ACTION" >
manevr_state =
//</DG2J>
 
					//-- НЕ ОПРЕДЕЛЕН
					
//<DG2J code_mark="n412:ACTION" >
MANEVR_UNKNOWN;
//</DG2J>
 
					//-- break
					
//<DG2J code_mark="n734:ACTION" >
break;
//</DG2J>
 
				//-- ВРАГ ОБНАРУЖЕН
				case 
//<DG2J code_mark="n394:CASE" >
Settings.SIT_ENEMY_DETECTED
//</DG2J>
:
					//-- Роль защитник конвоя?
					if(
//<DG2J code_mark="n480:IF" >
isRoleConvoyDefender()
//</DG2J>
) {
						//-- характер агрессивный?
						if(
//<DG2J code_mark="n422:IF" >
pepper_AI == AI_PEPPER_AGGRESSIVE
//</DG2J>
) {
							//-- маневр
							
//<DG2J code_mark="n464:ACTION" >
manevr_state =
//</DG2J>
 
							//-- ПОИСК ВРАГА АГРЕСС
							
//<DG2J code_mark="n463:ACTION" >
MANEVR_TARGET_SEARCH_AGGRESSIVE;
//</DG2J>
 
						} else {
							//-- характер скрытный?
							if(
//<DG2J code_mark="n465:IF" >
pepper_AI == AI_PEPPER_RESERVED
//</DG2J>
) {
								//-- маневр
								
//<DG2J code_mark="n468:ACTION" >
manevr_state =
//</DG2J>
 
								//-- ПОИСК ВРАГА ТИХИЙ
								
//<DG2J code_mark="n467:ACTION" >
MANEVR_TARGET_SEARCH_RESERVED;
//</DG2J>
 
							} else {
								//-- маневр
								
//<DG2J code_mark="n415:ACTION" >
manevr_state =
//</DG2J>
 
								//-- НЕ ОПРЕДЕЛЕН
								
//<DG2J code_mark="n414:ACTION" >
MANEVR_UNKNOWN;
//</DG2J>
 
							}
						}
					} else {
						//-- характер трусливый?
						if(
//<DG2J code_mark="n484:IF" >
pepper_AI == AI_PEPPER_COWARD
//</DG2J>
) {
							//-- маневр
							
//<DG2J code_mark="n483:ACTION" >
manevr_state =
//</DG2J>
 
							//-- ТИХОЕ БЕГСТВО
							
//<DG2J code_mark="n482:ACTION" >
MANEVR_RUNAWAY;
//</DG2J>
 
						} else {
							//-- маневр
							
//<DG2J code_mark="n486:ACTION" >
manevr_state =
//</DG2J>
 
							//-- НЕ ОПРЕДЕЛЕН
							
//<DG2J code_mark="n485:ACTION" >
MANEVR_UNKNOWN;
//</DG2J>
 
						}
					}
				//-- ВРАГ НА ДИСТ.ОГНЯ
				case 
//<DG2J code_mark="n395:CASE" >
Settings.SIT_ENEMY_ON_FIRE_DISTANCE
//</DG2J>
:
					//-- Роль защитник конвоя?
					if(
//<DG2J code_mark="n501:IF" >
isRoleConvoyDefender()
//</DG2J>
) {
						//-- характер агрессивный?
						if(
//<DG2J code_mark="n493:IF" >
pepper_AI == AI_PEPPER_AGGRESSIVE
//</DG2J>
) {
							//-- маневр
							
//<DG2J code_mark="n496:ACTION" >
manevr_state =
//</DG2J>
 
							//-- АТАКА АГРЕССИВНАЯ
							
//<DG2J code_mark="n495:ACTION" >
MANEVR_ATTACK_AGGRESSIVE;
//</DG2J>
 
						} else {
							//-- характер скрытный или трусливый?
							if(
//<DG2J code_mark="n497:IF" >
pepper_AI == AI_PEPPER_RESERVED || pepper_AI == AI_PEPPER_COWARD
//</DG2J>
) {
								//-- маневр
								
//<DG2J code_mark="n500:ACTION" >
manevr_state =
//</DG2J>
 
								//-- АТАКА ТИХАЯ
								
//<DG2J code_mark="n499:ACTION" >
MANEVR_ATTACK_SILENT;
//</DG2J>
 
							} else {
								//-- маневр
								
//<DG2J code_mark="n492:ACTION" >
manevr_state =
//</DG2J>
 
								//-- НЕ ОПРЕДЕЛЕН
								
//<DG2J code_mark="n491:ACTION" >
MANEVR_UNKNOWN;
//</DG2J>
 
							}
						}
					} else {
						//-- маневр
						
//<DG2J code_mark="n519:ACTION" >
manevr_state =
//</DG2J>
 
						//-- БЕГСТВО
						
//<DG2J code_mark="n518:ACTION" >
MANEVR_RUNAWAY;
//</DG2J>
 
						//-- характер
						switch(
//<DG2J code_mark="n515:SWITCH" >
pepper_AI
//</DG2J>
) {
							//-- СКРЫТНЫЙ
							case 
//<DG2J code_mark="n516:CASE" >
AI_PEPPER_RESERVED
//</DG2J>
:
								//-- маневр
								
//<DG2J code_mark="n504:ACTION" >
manevr_state =
//</DG2J>
 
								//-- ТИХОЕ БЕГСТВО
								
//<DG2J code_mark="n503:ACTION" >
MANEVR_RUNAWAY;
//</DG2J>
 
							//-- ТРУСЛИВЫЙ
							case 
//<DG2J code_mark="n517:CASE" >
AI_PEPPER_COWARD
//</DG2J>
:
								//-- маневр
								
//<DG2J code_mark="n513:ACTION" >
manevr_state =
//</DG2J>
 
								//-- ПАНИЧЕСКОЕ БЕГСТВО
								
//<DG2J code_mark="n512:ACTION" >
MANEVR_PANIC_RUNAWAY;
//</DG2J>
 
						}
					}
					//-- break
					
//<DG2J code_mark="n737:ACTION" >
break;
//</DG2J>
 
				//-- ВРАГ НЕ ОБНАРУЖЕН
				case 
//<DG2J code_mark="n393:CASE" >
Settings.SIT_NOENEMY
//</DG2J>
:
					//-- Роль защитник конвоя или нужно следовать в конвое?
					if(
//<DG2J code_mark="n479:IF" >
isRoleConvoyDefender() || isFolowConvoy()
//</DG2J>
) {
						//-- выбираем конвоируемое судно
						
//<DG2J code_mark="n397:ACTION" >
var c:Ship = selectConvoy();
//</DG2J>
 
						//-- нашли подконвойного?
						if(
//<DG2J code_mark="n398:IF" >
c != null
//</DG2J>
) {
							//-- были старые WP?
							if(
//<DG2J code_mark="n399:IF" >
way_points != null
//</DG2J>
) {
								//-- стираем WP и перкращаем движение к ним 
								
//<DG2J code_mark="n400:ACTION" >
stopMoveOnWayPoint();

//</DG2J>
 
							} else {
							}
							//-- устанавливаем WP точку конвоя
							
//<DG2J code_mark="n401:ACTION" >
var p:Point = c.getPosition()		.add(Point.polar(folow_convoy_dist,folow_convoy_angle));
addWayPoint(p.x, p.y, Constants.WP_CONVOY);

//</DG2J>
 
							//-- двигаемся с максимальной скоростью
							
//<DG2J code_mark="n402:ACTION" >
setPower(POWER_6);
//</DG2J>
 
							//-- начинаем движение к точке конвоя
							
//<DG2J code_mark="n403:ACTION" >
startMoveOnWP();
//</DG2J>
 
							//-- Производим конвоирование
							
//<DG2J code_mark="n416:ACTION" >
showInfoMessageForSelected("Производим конвоирование.");

//</DG2J>
 
							//-- маневр
							
//<DG2J code_mark="n409:ACTION" >
manevr_state =
//</DG2J>
 
							//-- КОНВОИРОВАНИЕ
							
//<DG2J code_mark="n408:ACTION" >
MANEVR_CONVOY_MOVING;
//</DG2J>
 
						} else {
							//-- Подконвойного не нашли
							
//<DG2J code_mark="n417:ACTION" >
showInfoMessageForSelected("Подконвойного не нашли.");

//</DG2J>
 
							//-- маневр
							
//<DG2J code_mark="n419:ACTION" >
manevr_state =
//</DG2J>
 
							//-- НЕ ОПРЕДЕЛЕН
							
//<DG2J code_mark="n418:ACTION" >
MANEVR_UNKNOWN;
//</DG2J>
 
						}
					} else {
						//-- маневр
						
//<DG2J code_mark="n411:ACTION" >
manevr_state =
//</DG2J>
 
						//-- НЕ ОПРЕДЕЛЕН
						
//<DG2J code_mark="n410:ACTION" >
MANEVR_UNKNOWN;
//</DG2J>
 
					}
					//-- break
					
//<DG2J code_mark="n735:ACTION" >
break;
//</DG2J>
 
				//-- ВРАГ РЯДОМ
				case 
//<DG2J code_mark="n396:CASE" >
Settings.SIT_ENEMY_CLOSE
//</DG2J>
:
					//-- Роль защитник конвоя?
					if(
//<DG2J code_mark="n505:IF" >
isRoleConvoyDefender()
//</DG2J>
) {
						//-- маневр
						
//<DG2J code_mark="n592:ACTION" >
manevr_state =
//</DG2J>
 
						//-- АТАКА АГРЕССИВНАЯ
						
//<DG2J code_mark="n591:ACTION" >
MANEVR_ATTACK_AGGRESSIVE;
//</DG2J>
 
					} else {
						//-- маневр
						
//<DG2J code_mark="n508:ACTION" >
manevr_state =
//</DG2J>
 
						//-- ПАНИЧЕСКОЕ БЕГСТВО
						
//<DG2J code_mark="n507:ACTION" >
MANEVR_PANIC_RUNAWAY;
//</DG2J>
 
					}
					//-- break
					
//<DG2J code_mark="n738:ACTION" >
break;
//</DG2J>
 
			}
		}
		//-- //--             
		
//<DG2J code_mark="n369:SH_END" >
}
//</DG2J>

	//-- AI_on_situation()
	
//<DG2J code_mark="n446:SH_BEG" >
public function AI_on_situation():void {
//</DG2J>
 
		//-- маневр
		switch(
//<DG2J code_mark="n449:SWITCH" >
manevr_state
//</DG2J>
) {
			//-- ПОИСК ВРАГА АГРЕСС
			case 
//<DG2J code_mark="n451:CASE" >
MANEVR_TARGET_SEARCH_AGGRESSIVE
//</DG2J>
:
				//-- двигаемся с максимальной скоростью
				
//<DG2J code_mark="n471:ACTION" >
setPower(POWER_6);
//</DG2J>
 
				//-- Двигаемся в предполагаемом направлении на цель
				
//<DG2J code_mark="n452:ACTION" >
//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg);

//</DG2J>
 
				//-- Агрес поиск. Двигаемся в предполагаемом направлении на цель
				
//<DG2J code_mark="n453:ACTION" >
showInfoMessageForSelected("Агрес поиск. Двигаемся в предполагаемом направлении на цель." + angle_deg.toFixed(3));

//</DG2J>
 
				//-- break
				
//<DG2J code_mark="n740:ACTION" >
break;
//</DG2J>
 
			//-- ТИХОЕ БЕГСТВО
			case 
//<DG2J code_mark="n488:CASE" >
MANEVR_RUNAWAY
//</DG2J>
:
				//-- двигаемся с максимально тихой скоростью не меньше 1
				
//<DG2J code_mark="n597:ACTION" >
var dist:Number = Point.distance(position_gm, situation.target.ship.getPosition());
var pow:int = POWER_6;
while(pow > POWER_1) {
	var ns:Number =  VehicleMoving.calcNoise(this.noisy, pow, dist);
	if (ns < Settings.NOISE_TRAKCING_RANGE) 
		break;
	pow--;	
}

setPower(pow);

//</DG2J>
 
				//-- Двигаемся в противоположном направлении от цели
				
//<DG2J code_mark="n489:ACTION" >
//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg+180.);

//</DG2J>
 
				//-- Тихое бегство. Тихо двигаемся в противоположном направлении от врага.
				
//<DG2J code_mark="n490:ACTION" >
showInfoMessageForSelected("Тихое бегство. Тихо двигаемся в противоположном направлении от врага.");

//</DG2J>
 
				//-- break
				
//<DG2J code_mark="n742:ACTION" >
break;
//</DG2J>
 
			//-- АТАКА ТИХАЯ
			case 
//<DG2J code_mark="n579:CASE" >
MANEVR_ATTACK_SILENT
//</DG2J>
:
				//-- двигаемся с максимально тихой скоростью не меньше 1
				
//<DG2J code_mark="n600:ACTION" >
var dist:Number = Point.distance(position_gm, situation.target.ship.getPosition());
var pow:int = POWER_6;
while(pow > POWER_1) {
	var ns:Number =  VehicleMoving.calcNoise(this.noisy, pow, dist);
	if (ns < Settings.NOISE_TRAKCING_RANGE) 
		break;
	pow--;	
}

setPower(pow);

//</DG2J>
 
				//-- Двигаемся в противоположном направлении от цели
				
//<DG2J code_mark="n580:ACTION" >
//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg+180.);

//</DG2J>
 
				//-- Открываем огонь
				
//<DG2J code_mark="n577:ACTION" >
AI_torped_fire();
//</DG2J>
 
				//-- Тихая атака. Подкрадываемся и атакуем.
				
//<DG2J code_mark="n583:ACTION" >
showInfoMessageForSelected("Тихая атака. Подкрадываемся и атакуем.");

//</DG2J>
 
				//-- break
				
//<DG2J code_mark="n744:ACTION" >
break;
//</DG2J>
 
			//-- ПАНИЧЕСКОЕ БЕГСТВО
			case 
//<DG2J code_mark="n509:CASE" >
MANEVR_PANIC_RUNAWAY
//</DG2J>
:
				//-- двигаемся с максимальной скоростью
				
//<DG2J code_mark="n598:ACTION" >
setPower(POWER_6);
//</DG2J>
 
				//-- Двигаемся в противоположном направлении от цели
				
//<DG2J code_mark="n510:ACTION" >
//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg+180.);

//</DG2J>
 
				//-- Паническое бегство. Удираем в противоположном направлении от врага.
				
//<DG2J code_mark="n511:ACTION" >
showInfoMessageForSelected("Паническое бегство. Удираем в противоположном направлении от врага.");

//</DG2J>
 
				//-- break
				
//<DG2J code_mark="n743:ACTION" >
break;
//</DG2J>
 
			//-- АТАКА АГРЕССИВНАЯ
			case 
//<DG2J code_mark="n578:CASE" >
MANEVR_ATTACK_AGGRESSIVE
//</DG2J>
:
				//-- двигаемся с максимальной скоростью
				
//<DG2J code_mark="n599:ACTION" >
setPower(POWER_6);
//</DG2J>
 
				//-- Двигаемся в противоположном направлении от цели
				
//<DG2J code_mark="n581:ACTION" >
//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg+180.);

//</DG2J>
 
				//-- Открываем огонь
				
//<DG2J code_mark="n582:ACTION" >
AI_torped_fire();
//</DG2J>
 
				//-- Агрессивная атака. Движемся на врага с максимальной скоростью и открываем огонь.
				
//<DG2J code_mark="n584:ACTION" >
showInfoMessageForSelected("Агрессивная атака. Движемся на врага с максимальной скоростью и открываем огонь.");

//</DG2J>
 
				//-- break
				
//<DG2J code_mark="n745:ACTION" >
break;
//</DG2J>
 
			//-- ПОИСК ВРАГА ТИХИЙ
			case 
//<DG2J code_mark="n469:CASE" >
MANEVR_TARGET_SEARCH_RESERVED
//</DG2J>
:
				//-- дистанция 
				if(
//<DG2J code_mark="n475:IF" >
situation.target.distance < torp_params_III.dist_execution * 0.2
//</DG2J>
) {
					//-- устанавливаем WP на боковую точку
					
//<DG2J code_mark="n473:ACTION" >
var p:Point;
//-- в какую сторону поворачивать выбираем случайно
if(Math.random()>0.5)
	p = Point.polar(200., Utils.toScreenRad(direction_deg + 110)); 
else 
	p = Point.polar(100., Utils.toScreenRad(direction_deg - 110)); 
var p2:Point = position_gm.add(p);
addWayPoint(p2.x, p2.y, Constants.WP_TARGET);

//</DG2J>
 
				} else {
					//-- двигаемся с максимально тихой скоростью не меньше 1
					
//<DG2J code_mark="n596:ACTION" >
var dist:Number = Point.distance(position_gm, situation.target.ship.getPosition());
var pow:int = POWER_6;
while(pow > POWER_1) {
	var ns:Number =  VehicleMoving.calcNoise(this.noisy, pow, dist);
	if (ns < Settings.NOISE_TRAKCING_RANGE) 
		break;
	pow--;	
}

setPower(pow);

//</DG2J>
 
					//-- Двигаемся в предполагаемом направлении на цель
					
//<DG2J code_mark="n476:ACTION" >
//-- вычисляем направление на цель
var angle_deg:Number = Utils.calcAngleBattleDeg(position_gm, situation.target.ship.getPosition());
startMoveInDirectionDeg(angle_deg);

//</DG2J>
 
				}
				//-- Тихий поиск. Двигаемся в предполагаемом направлении на цель
				
//<DG2J code_mark="n470:ACTION" >
showInfoMessageForSelected("Тихий поиск. Двигаемся в предполагаемом направлении на цель." + angle_deg.toFixed(3));

//</DG2J>
 
				//-- break
				
//<DG2J code_mark="n741:ACTION" >
break;
//</DG2J>
 
			//-- НЕ ОПРЕДЕЛЕН
			case 
//<DG2J code_mark="n450:CASE" >
MANEVR_UNKNOWN
//</DG2J>
:
				//-- break
				
//<DG2J code_mark="n739:ACTION" >
break;
//</DG2J>
 
		}
		//-- //--             
		
//<DG2J code_mark="n448:SH_END" >
}
//</DG2J>

	//-- Заполняет список мишеней
	
//<DG2J code_mark="n271:SH_BEG" >
public function fillAllTarget():void {
//</DG2J>
 
		//-- Заполняет список мишеней//-- - чистим список мишеней
		
//<DG2J code_mark="n273:ACTION" >
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

//</DG2J>
 
		//-- //--             
		
//<DG2J code_mark="n274:SH_END" >
}
//</DG2J>

	//-- (AI) Выбор цели 
	
//<DG2J code_mark="n305:SH_BEG" >
/**
			 * Выбор цели на которую начинаем охоту
			 * сейчас возвращается самая громкая
			 * 
			 * overrided для Ship и Torpedo 
			 */ 
			override public function selectTarget():Target {
//</DG2J>
 
		//-- определяем перемнные
		
//<DG2J code_mark="n198:ACTION" >
var ret_trg:Target;
var ns:Number = 0;
//</DG2J>
 
		//-- для всех целей
		
//<DG2J code_mark="n199:FOR_BEG" >
for each(var trg:Target in targets) {
//</DG2J>

			//-- выбираем самую громкую цель
			
//<DG2J code_mark="n200:ACTION" >
if(ns == 0) {
	ns = trg.noise;	
	ret_trg = trg;
} else if (trg.noise > ns) {
	ret_trg = trg;
	ns = trg.noise;
}
//</DG2J>
 
		}
		//-- возвр. цель
		
//<DG2J code_mark="n303:SH_END" >
return ret_trg;
}
//</DG2J>

	//-- Проверка наличия торпедной атаки
	
//<DG2J code_mark="n306:SH_BEG" >
			/*
			 * Проверка наличия торпедной атаки
			 * 
			 * Проверяем для всех торпед и выбираем ближайшую.
			 * Возвращает атакующую торпеду.
			 */ 
			public function checkTrpAtack():Torped {

//</DG2J>
 
		//-- тело процедуры
		
//<DG2J code_mark="n203:ACTION" >
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
//</DG2J>
 
		//-- возвр. угр торпеду
		
//<DG2J code_mark="n373:SH_END" >
return null;
}
//</DG2J>

	//-- (AI) Противоторпедный маневр
	
//<DG2J code_mark="n308:SH_BEG" >
protected function antyTorpManevr(t:Torped):void {
//</DG2J>
 
		//-- определяем дистанцию до угрожающей Т
		
//<DG2J code_mark="n265:ACTION" >
var dist:Number = Point.distance(position_gm, t.getPosition());
//</DG2J>
 
		//-- торпеда далеко?
		if(
//<DG2J code_mark="n262:IF" >
dist > Settings.TRP_ATACK_ALARM_DIST
//</DG2J>
) {
			//-- угол уклонения TRP_ATACK_DEFENSE_ANGLE
			
//<DG2J code_mark="n261:ACTION" >
var angle = Settings.TRP_ATACK_DEFENSE_ANGLE;

//</DG2J>
 
			//-- Неподвижен?
			if(
//<DG2J code_mark="n267:IF" >
getPower() == POWER_0
//</DG2J>
) {
				//-- двигаемся с тихой скоростью
				
//<DG2J code_mark="n268:ACTION" >
setPower(POWER_1);
//</DG2J>
 
			} else {
			}
		} else {
			//-- угол уклонения //-- 90
			
//<DG2J code_mark="n264:ACTION" >
var angle = 90; 
//</DG2J>
 
			//-- двигаемся с максимальной скоростью
			
//<DG2J code_mark="n266:ACTION" >
setPower(POWER_6);
//</DG2J>
 
		}
		//-- стираем WP и перкращаем движение к ним 
		
//<DG2J code_mark="n270:ACTION" >
stopMoveOnWayPoint();

//</DG2J>
 
		//-- вырабатываем точку уклонения пока не выйдем из атаки//-- в какую сторону поворачивать выбираем случайно
		
//<DG2J code_mark="n258:ACTION" >
var p:Point;
//-- в какую сторону поворачивать выбираем случайно
if(Math.random()>0.5)
	p = Point.polar(100., Utils.toScreenRad(direction_deg + angle)); 
else 
	p = Point.polar(100., Utils.toScreenRad(direction_deg - angle)); 
var p2:Point = position_gm.add(p);
//</DG2J>
 
		//-- устанавливаем WP на точку уклонения
		
//<DG2J code_mark="n259:ACTION" >
addWayPoint(p2.x, p2.y, Constants.WP_TORP_DEFENCE);
//</DG2J>
 
		//-- начинаем движение к точке уклонения
		
//<DG2J code_mark="n260:ACTION" >
startMoveOnWP();
//</DG2J>
 
		//-- //--         
		
//<DG2J code_mark="n797:SH_END" >
}
//</DG2J>

	//--  Маневр УКОЛ
	
//<DG2J code_mark="n309:SH_BEG" >
/*
 * Маневр УКОЛ
 */ 
protected function manevrStick():void  {

//</DG2J>
 
		//-- тело процедуры
		
//<DG2J code_mark="n257:ACTION" >
//-- переопределить в дочерних классах
//</DG2J>
 
		//-- //--         
		
//<DG2J code_mark="n796:SH_END" >
}
//</DG2J>

	//-- (AI) Выбор оружия
	
//<DG2J code_mark="n310:SH_BEG" >
			/**
			 * Выбор оружия по параметрам цели и степени его готовности
			 */ 
			protected function AI_select_weapon(_target:Ship):TorpedParams {

//</DG2J>
 
		//-- задаем переменные
		
//<DG2J code_mark="n283:ACTION" >
var torp_params:TorpedParams;
var dist_max_III:Number;


//</DG2J>
 
		//-- определяем дистанцию до цели
		
//<DG2J code_mark="n275:ACTION" >
var dist:Number = Point.distance(position_gm, _target.getPosition());
//</DG2J>
 
		//-- рассчитываем дистанцию стрельбы для оружия III
		
//<DG2J code_mark="n276:ACTION" >
dist_max_III = torp_params_III.dist_execution;
//dist_max_III = torp_params_III.max_time_life_sec * 1000. *  torp_params_III.max_velocity_hum * Settings.koef_v;

//</DG2J>
 
		//-- для типа III далеко?
		if(
//<DG2J code_mark="n277:IF" >
dist > dist_max_III
//</DG2J>
) {
			//-- сообщение для выбранного "Выбрано оружие I"
			
//<DG2J code_mark="n281:ACTION" >
if (display_selected) {
	Main.main.getInformer().writeDebugText("Выбрано оружие I");
}

//</DG2J>
 
			//-- текущие параметры - тип I
			
//<DG2J code_mark="n279:ACTION" >
torp_params = torp_params_I;
//</DG2J>
 
		} else {
			//-- сообщение для выбранного "Выбрано оружие III"
			
//<DG2J code_mark="n282:ACTION" >
if (display_selected) {
	Main.main.getInformer().writeDebugText("Выбрано оружие III");
}

//</DG2J>
 
			//-- текущие параметры - тип III
			
//<DG2J code_mark="n278:ACTION" >
torp_params = torp_params_III;
//</DG2J>
 
		}
		//-- возвр. выбранные параметры
		
//<DG2J code_mark="n601:SH_END" >
return torp_params;
}
//</DG2J>

	//-- исполнение
	
//<DG2J code_mark="n190:SH_BEG" >
public function AI_step_III():void  {
//</DG2J>
 
		//-- строим код
		
//<DG2J code_mark="n193:ACTION" >
/*var ret_code:String = "";
ret_code += enemy.getName();
ret_code += " "+situation;
ret_code += " "+enemy_ship_type;
ret_code += " "+enemy_dist_change;
*/
//</DG2J>
 
		//-- //--             
		
//<DG2J code_mark="n194:SH_END" >
}
//</DG2J>

	//-- AI_torped_fire()
	
//<DG2J code_mark="n546:SH_BEG" >
			/**
			 * 
			 * Выбор торпеды
			 * Рассчет точки выстрела для прямолинейно движущихся торпед.
			 * Можно улучшить алгоритм повысив точность за счет второго цикла итераций
			 * 
			 */
			public function AI_torped_fire():void {

//</DG2J>
 
		//-- локальные переменные
		
//<DG2J code_mark="n524:ACTION" >
var _getMaxTimeLifeSec:Number;		
var _getMaxVelocity:Number;
var _getWeaponType:int;
var fire_state: int = 0; 
var cur_torp_app:TorpedApp;
//</DG2J>
 
		//-- торпеды перезаряжены?
		if(
//<DG2J code_mark="n525:IF" >
isTorpedReady()
//</DG2J>
) {
			//-- цель есть?
			if(
//<DG2J code_mark="n527:IF" >
situation.target != null
//</DG2J>
) {
				//-- корабль цели  есть?
				if(
//<DG2J code_mark="n530:IF" >
situation.target.ship != null
//</DG2J>
) {
					//-- время запуска
					
//<DG2J code_mark="n794:ACTION" >
var start_time:int = 
//</DG2J>
 
					//-- getTimer()
					
//<DG2J code_mark="n531:ACTION" >
getTimer();
//</DG2J>
 
					//-- выбираем оружие для цели
					
//<DG2J code_mark="n588:ACTION" >
var torp_params:TorpedParams =  AI_select_weapon(situation.target.ship);

//</DG2J>
 
					//-- Выбор сделан?
					if(
//<DG2J code_mark="n587:IF" >
torp_params != null
//</DG2J>
) {
						//-- узнаем тип оружия
						
//<DG2J code_mark="n589:ACTION" >
_getWeaponType = torp_params.weapon_type;
//</DG2J>
 
						//-- оружие типа I?
						if(
//<DG2J code_mark="n532:IF" >
_getWeaponType == Constants.WEAPON_SELECT_TORP_I
//</DG2J>
) {
							//-- текущий аппарат оружия типа I
							
//<DG2J code_mark="n533:ACTION" >
cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_I);
//</DG2J>
 
						} else {
							//-- оружие типа II?
							if(
//<DG2J code_mark="n535:IF" >
_getWeaponType == Constants.WEAPON_SELECT_TORP_II
//</DG2J>
) {
								//-- текущий аппарат оружия типа II
								
//<DG2J code_mark="n536:ACTION" >
cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_II);
//</DG2J>
 
							} else {
								//-- оружие типа III?
								if(
//<DG2J code_mark="n537:IF" >
_getWeaponType == Constants.WEAPON_SELECT_TORP_III
//</DG2J>
) {
									//-- текущий аппарат оружия типа III
									
//<DG2J code_mark="n538:ACTION" >
cur_torp_app = isWeaponReady(Constants.WEAPON_SELECT_TORP_III);
//</DG2J>
 
								} else {
									//-- текущий аппарат оружия не выбран
									
//<DG2J code_mark="n542:ACTION" >
cur_torp_app = null;
//</DG2J>
 
								}
							}
						}
						//-- текущий аппарат готов?
						if(
//<DG2J code_mark="n534:IF" >
cur_torp_app != null
//</DG2J>
) {
							//-- берем максимальную скорость и время жизни для выбранного оружия
							
//<DG2J code_mark="n539:ACTION" >
_getMaxTimeLifeSec = torp_params.max_time_life_sec;
		_getMaxVelocity = torp_params.max_velocity_hum;
//</DG2J>
 
							//-- вспомогательные переменные
							
//<DG2J code_mark="n547:ACTION" >
var target_position:Point;
var len:Number; 
var torpedo_position:Point;
var target_position2:Point;
var t_ms:Number = 0; 

var vp:VehicleParams = new VehicleParams(situation.target.ship.position_gm
	,situation.target.ship.velocity_gm
	,situation.target.ship.direction_deg); 
target_position2 = situation.target.ship.position_gm;

//</DG2J>
 
							//-- вычисляем dt //-- = время жизни / AI_torped_fire_interva
							
//<DG2J code_mark="n551:ACTION" >
var dt:Number = _getMaxTimeLifeSec * 1000. / Settings.AI_torped_fire_interval; // * 5.;
;
//</DG2J>
 
							//-- интегация 
							
//<DG2J code_mark="n548:FOR_BEG" >
for(var i:int = 1; i < Settings.AI_torped_fire_interval; i++) {
//</DG2J>

								//-- t_ms += dt;
								
//<DG2J code_mark="n550:ACTION" >
t_ms += dt;
//</DG2J>
 
								//-- время жизни вышло?
								if(
//<DG2J code_mark="n552:IF" >
t_ms > _getMaxTimeLifeSec * 1000
//</DG2J>
) {
									//-- return
									
//<DG2J code_mark="n698:ACTION" >
return;
//</DG2J>
 
								} else {
								}
								//-- рассчитываем положение цели в момент времени dt ПРЯМОЛИНЕЙНЫЙ АЛГОРИТМ
								
//<DG2J code_mark="n554:ACTION" >
var p:Point = Point.polar(t_ms * situation.target.ship.getVelocity()
   , Utils.toScreenRad(situation.target.ship.getDirection()));
target_position = situation.target.ship.getPosition().add(p);

//</DG2J>
 
								//-- рассчитываем положение цели в момент времени t. УЧИТЫВАЕТСЯ ТЕКУЩИЙ МАНЕВР ЦЕЛИ
								
//<DG2J code_mark="n555:ACTION" >
vp = VehicleMoving.move_calc_pos2(dt, vp, situation.target.ship.getCommandParams()
	, situation.target.ship.max_velocity_hum,	situation.target.ship.manevr_prc);
target_position2 = vp.position;

//</DG2J>
 
								//-- Рисовать расчет?
								if(
//<DG2J code_mark="n557:IF" >
Settings.DRAW_TORPED_CALC
//</DG2J>
) {
									//-- рисуем точки вчтречи по линейному алгоритму и по второму
									
//<DG2J code_mark="n558:ACTION" >
var c:CustomCircle = new CustomCircle(target_position.x, target_position.y, 2, 0xffff00);
c.x = main.toDisplayX(c.getX());
c.y = main.toDisplayX(c.getY());
main.addChild(c);

var c2:CustomCircle = new CustomCircle(target_position2.x, target_position2.y, 2, 0xff00ff);
c2.x = main.toDisplayX(c2.getX());
c2.y = main.toDisplayX(c2.getY());
main.addChild(c2);

//</DG2J>
 
								} else {
								}
								//-- рассчитываем расстояни которое пройдет торпеда и расстояние от нас до цели 
								
//<DG2J code_mark="n560:ACTION" >
//-- за время t торпеда пройдет 
len = t_ms * _getMaxVelocity * Settings.koef_v ; 
//-- рассчитываем расстояние от нашей позиции до target.ship_position
var dist:Number = Point.distance(this.position_gm, target_position2);

//</DG2J>
 
								//-- Торпеда дойдет до цели?
								if(
//<DG2J code_mark="n561:IF" >
len > dist
//</DG2J>
) {
									//-- вычисляем точку встречи//-- и направление выстрела
									
//<DG2J code_mark="n562:ACTION" >
var atak_point:Point = target_position2.subtract(position_gm);
var angle:Number = Utils.calcAngle(0, 0, atak_point.x, atak_point.y);
var torp:Torped;
//</DG2J>
 
									//-- Я подлодка?
									if(
//<DG2J code_mark="n564:IF" >
this is Sub
//</DG2J>
) {
										//-- Выбранное оружие торпеда II?
										if(
//<DG2J code_mark="n565:IF" >
_getWeaponType == Constants.WEAPON_SELECT_TORP_II
//</DG2J>
) {
											//-- Пуск торпеды II в расчетную точку 
											
//<DG2J code_mark="n585:ACTION" >
showInfoMessageForSelected("Пуск торпеды II в расчетную точку ."+target_position2.x.toFixed(0));

//</DG2J>
 
											//-- выстрел в рассчитанную //-- позицию
											
//<DG2J code_mark="n566:ACTION" >
torp = fireAtPosition(_getWeaponType, 	target_position2);
//</DG2J>
 
										} else {
											//-- Пуск торпеды I,II в направлении движения
											
//<DG2J code_mark="n586:ACTION" >
showInfoMessageForSelected("Пуск торпеды I,II в направлении движения.");

//</DG2J>
 
											//-- выстрел в //-- направлении движения
											
//<DG2J code_mark="n567:ACTION" >
torp = fire_in_direction(_getWeaponType,getDirection());
//main.fire_in_direction(this, Utils.toBattleDegree(angle), _getWeaponType);
//cur_torp_app.onFire();
//</DG2J>
 
										}
										//-- выстрел произошел?
										if(
//<DG2J code_mark="n569:IF" >
torp != null
//</DG2J>
) {
										} else {
											//-- return
											
//<DG2J code_mark="n696:ACTION" >
return;
//</DG2J>
 
										}
										//-- регистрация торпеды,//-- торпедный аппарат выстрелил
										
//<DG2J code_mark="n571:ACTION" >
main.registerTorped(torp,getForces());
cur_torp_app.onFire();

//</DG2J>
 
									} else {
										//-- Пуск торпеды I,II в направлении движения
										
//<DG2J code_mark="n695:ACTION" >
showInfoMessageForSelected("Пуск торпеды I,II в направлении движения.");

//</DG2J>
 
										//-- выстрел в направлении расч.точки,торпедный аппарат выстрелил
										
//<DG2J code_mark="n573:ACTION" >
main.fire_in_direction(this, Utils.toBattleDegree(angle), _getWeaponType);
cur_torp_app.onFire();

//</DG2J>
 
									}
									//-- если нужно, рисуем точки вчтречи по линейному алгоритму и по второму
									
//<DG2J code_mark="n574:ACTION" >
if(Settings.DRAW_TORPED_CALC) {
var p1:Point = Point.polar(dist, angle);
var p2:Point = p1.add(position_gm);
c2 = new CustomCircle(p2.x, p2.y, 3, 0xFF6347);
c2.x = main.toDisplayX(c2.getX());
c2.y = main.toDisplayX(c2.getY());
main.addChild(c2);
}
//</DG2J>
 
									//-- перываем расчёт
									
//<DG2J code_mark="n697:ACTION" >
break;
//</DG2J>
 
								} else {
								}
							}
							//-- увеличиваем время потраченное на работу AI
							
//<DG2J code_mark="n575:ACTION" >
Statistic.AI_calc_time += getTimer() - start_time;

//</DG2J>
 
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
		
//<DG2J code_mark="n576:SH_END" >
}
//</DG2J>

	//-- fire_in_direction()
	
//<DG2J code_mark="n307:SH_BEG" >
public function fire_in_direction(_weapon_select:int, dir_deg:Number):Torped {

//</DG2J>
 
		//-- тело процедуры
		
//<DG2J code_mark="n296:ACTION" >
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

//</DG2J>
 
		//-- возвр. торпеду
		
//<DG2J code_mark="n302:SH_END" >
return torp;
}
//</DG2J>

	//-- выход
	
//<DG2J code_mark="n700:SH_BEG" >
null
//</DG2J>
 
		//-- isWeaponReady()
		
//<DG2J code_mark="n255:ACTION" >
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
//</DG2J>
 
		//-- calcNoiseAtDist()
		
//<DG2J code_mark="n218:ACTION" >
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
//</DG2J>
 
		//-- selectConvoy()
		
//<DG2J code_mark="n219:ACTION" >
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
//</DG2J>
 
		//-- onSlowLoop()//-- getStore()
		
//<DG2J code_mark="n221:ACTION" >
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
//</DG2J>
 
		//-- getTorpOnBoard()
		
//<DG2J code_mark="n214:ACTION" >
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

//</DG2J>
 
		//-- hasHit()
		
//<DG2J code_mark="n240:ACTION" >
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
//</DG2J>
 
		//-- isTorpedReady()
		
//<DG2J code_mark="n294:ACTION" >
protected function isTorpedReady():Boolean {
 
		//-- просто проверяем прошло ли положенное время с момента последнего выстрела
		return (getTimer() - time_torp_fire) > 
		time_reload_torped_ms  + Math.random() * time_reload_torped_ms/2.;
		//-- выход
		
		
	}
//</DG2J>
 
		//-- setAggressivePepper()//-- setReservedPepper()
		
//<DG2J code_mark="n461:ACTION" >
public function setAggressivePepper() {
	pepper_AI = AI_PEPPER_AGGRESSIVE;
}
public function setReservedPepper() {
	pepper_AI = AI_PEPPER_RESERVED;
}
public function setCowardPepper() {
	pepper_AI = AI_PEPPER_COWARD;
}

//</DG2J>
 
		//-- fireAtPosition()
		
//<DG2J code_mark="n253:ACTION" >
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

//</DG2J>
 
		//-- drawTargets()
		
//<DG2J code_mark="n250:ACTION" >
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
//</DG2J>
 
		//-- draw_ship_sub()
		
//<DG2J code_mark="n248:ACTION" >
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
//</DG2J>
 
		//-- draw_ship()//-- draw_ship_0()
		
//<DG2J code_mark="n246:ACTION" >
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
//</DG2J>
 
		//-- draw_ship_selected()
		
//<DG2J code_mark="n244:ACTION" >
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
//</DG2J>
 
		//-- drawShip()
		
//<DG2J code_mark="n242:ACTION" >
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
//</DG2J>
 
		//-- infoText()
		
//<DG2J code_mark="n238:ACTION" >
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
//</DG2J>
 
		//-- getResolvStr()
		
//<DG2J code_mark="n233:ACTION" >
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

//</DG2J>
 
		//-- setDispalySelected()
		
//<DG2J code_mark="n210:ACTION" >
public function setDispalySelected(ds:Boolean) {
display_selected = ds;
}
	

//</DG2J>
 
		//-- showTarget()//-- showInfoMessageForSelected()
		
//<DG2J code_mark="n211:ACTION" >
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

//</DG2J>
 
		//-- selectOnDisplay()
		
//<DG2J code_mark="n223:ACTION" >
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
//</DG2J>
 
		//-- underControl()
		
//<DG2J code_mark="n225:ACTION" >
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
//</DG2J>
 
		//-- setTimeReloadTorped()//-- getTimeReloadTorpSec()
		
//<DG2J code_mark="n236:ACTION" >
		public function setTimeReloadTorped(t_sec:Number):void
		{
			time_reload_torped_ms = t_sec * 1000;
		}
		
		public function getTimeReloadTorpSec():Number
		{
			return time_reload_torped_ms / 1000;
		}

//</DG2J>
 
		//-- setRoleConvoyDefender()//-- isRoleConvoyDefender()
		
//<DG2J code_mark="n235:ACTION" >
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

//</DG2J>
 
		//-- setConvoy()//-- isConvoy()
		
//<DG2J code_mark="n229:ACTION" >
public function setConvoy(_convoy:Boolean):void
		{
			convoy = _convoy;
		}
		
		public function isConvoy():Boolean
		{
			return convoy;
		}
//</DG2J>
 
		//-- setFollowConvoy()
		
//<DG2J code_mark="n431:ACTION" >
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
//</DG2J>
 
		//-- setAntyTorpManevr()
		
//<DG2J code_mark="n212:ACTION" >
public function setAntyTorpManevr(_anty_torp_manevr:Boolean):void {
	anty_torp_manevr = _anty_torp_manevr;
}

//</DG2J>
 
		//-- addTarget()
		
//<DG2J code_mark="n227:ACTION" >
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
//</DG2J>
 
		//-- get/set SizeForHit
		
//<DG2J code_mark="n216:ACTION" >
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
		
//</DG2J>
 
		//-- get/set Health//-- set NoHitDamage
		
//<DG2J code_mark="n209:ACTION" >
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
//</DG2J>
 
		//-- конец
		
//<DG2J code_mark="n699:SH_END" >
//}
//</DG2J>

	//-- 
            
	
//<DG2J code_mark="n795:SI_END" >
   } //-- конец класса
} //-- крнец пакета
//</DG2J>
 
