
//-- Класс Ситуация 1x1

//<DG2J code_mark="n774:SI_BEG" >
null
//</DG2J>

	//-- упоминание о DrakonGen
	
//<DG2J code_mark="n92:ACTION" >
   /**
    * Этот текст сгенерирован программой DrakonGen
    * @author Erv
    */

//</DG2J>
 
	//-- package//-- imports
	
//<DG2J code_mark="n90:ACTION" >
package  srs.AI
{
   import flash.display.Sprite;
   import flash.geom.Point;
   import srs.ships.Ship;
   import srs.ships.Sub;
   import srs.Settings;
   import srs.ships.Torped;
   import srs.ships.Target;

//</DG2J>
 
	//-- class Situation1x1
	
//<DG2J code_mark="n91:ACTION" >
   /**
    * ...
    * @author Erv
    */
   public class Situation1x1 {


//</DG2J>
 
	//-- переменные
	
//<DG2J code_mark="n93:ACTION" >
public var situation:String = Settings.SIT_NOENEMY;
public var enemy_ship_type:String = Settings.EST_UNKNOWN;

public var enemy_dist_change:String = Settings.DC_UNKNOWN;
//public var enemy:Ship;
public var target:Target = null;

public var me:Ship;
protected var mem_dist:Number = -1;

//-- угрожающая торпеда
public var danger_torp:Torped;


//</DG2J>
 
	//-- Situation1x1()
	
//<DG2J code_mark="n186:SH_BEG" >
public function Situation1x1(_me:Ship) {
//</DG2J>
 
		//-- я
		
//<DG2J code_mark="n113:ACTION" >
me =
//</DG2J>
 
		//-- из параметра
		
//<DG2J code_mark="n112:ACTION" >
_me;
//</DG2J>
 
		//-- враг
		
//<DG2J code_mark="n115:ACTION" >
target =
//</DG2J>
 
		//-- null
		
//<DG2J code_mark="n114:ACTION" >
null;
//</DG2J>
 
		//-- ситуация
		
//<DG2J code_mark="n140:ACTION" >
situation =
//</DG2J>
 
		//-- ВРАГ НЕ ОБНАРУЖЕН
		
//<DG2J code_mark="n139:ACTION" >
Settings.SIT_NOENEMY;
//</DG2J>
 
		//-- тип врага
		
//<DG2J code_mark="n137:ACTION" >
enemy_ship_type =
//</DG2J>
 
		//-- НЕ ОПРЕДЕЛЕН
		
//<DG2J code_mark="n136:ACTION" >
Settings.EST_UNKNOWN;
//</DG2J>
 
		//-- изменение дистанции
		
//<DG2J code_mark="n135:ACTION" >
enemy_dist_change =
//</DG2J>
 
		//-- НЕОПРЕДЕЛЕНО
		
//<DG2J code_mark="n134:ACTION" >
Settings.DC_UNKNOWN;
//</DG2J>
 
		//-- //--         
		
//<DG2J code_mark="n760:SH_END" >
}
//</DG2J>

	//-- оценка ситуации
	
//<DG2J code_mark="n158:SH_BEG" >
public function detectSituation():void {
//</DG2J>
 
		//-- Проверка наличия //-- торпедной атаки
		
//<DG2J code_mark="n289:ACTION" >
danger_torp = me.checkTrpAtack();
//</DG2J>
 
		//-- есть угроза жизни?
		if(
//<DG2J code_mark="n285:IF" >
danger_torp != null
//</DG2J>
) {
			//-- получаем данные угрозы
			
//<DG2J code_mark="n286:ACTION" >
//-- null
//</DG2J>
 
			//-- ситуация
			
//<DG2J code_mark="n292:ACTION" >
situation =
//</DG2J>
 
			//-- НАС АТАКУЕТ ТОРПЕДА
			
//<DG2J code_mark="n291:ACTION" >
Settings.SIT_UNDER_TRP_ATTACK;
//</DG2J>
 
		} else {
			//-- (AI) Выбор цели 
			
//<DG2J code_mark="n288:ACTION" >
target = me.selectTarget();


//</DG2J>
 
			//-- враг есть?
			if(
//<DG2J code_mark="n287:IF" >
target != null
//</DG2J>
) {
				//-- вычисляем дистанцию до цели
				
//<DG2J code_mark="n290:ACTION" >
var dist:Number = 100000000000000;
target.distance = Point.distance(me.getPosition(), target.ship.getPosition());
dist = target.distance;
	

//</DG2J>
 
				//-- вычисляем шум цели
				
//<DG2J code_mark="n116:ACTION" >
var ns:Number = target.ship.calcNoiseAtDist(dist);
			target.noise = ns;

//</DG2J>
 
				//-- враг виден?
				if(
//<DG2J code_mark="n96:IF" >
ns >= 0.2
//</DG2J>
) {
					//-- враг ОБНАРУЖЕН?
					if(
//<DG2J code_mark="n97:IF" >
ns >= 0.2 && ns < 0.5
//</DG2J>
) {
						//-- ситуация
						
//<DG2J code_mark="n109:ACTION" >
situation =
//</DG2J>
 
						//-- ВРАГ ОБНАРУЖЕН
						
//<DG2J code_mark="n108:ACTION" >
Settings.SIT_ENEMY_DETECTED
//</DG2J>
 
						//-- тип врага
						
//<DG2J code_mark="n105:ACTION" >
enemy_ship_type =
//</DG2J>
 
						//-- НЕ ОПРЕДЕЛЕН
						
//<DG2J code_mark="n104:ACTION" >
Settings.EST_UNKNOWN;
//</DG2J>
 
					} else {
						//-- Враг НА ДИСТ.ОГНЯ?
						if(
//<DG2J code_mark="n98:IF" >
ns >= 0.5 && ns < 0.8
//</DG2J>
) {
							//-- ситуация
							
//<DG2J code_mark="n107:ACTION" >
situation =
//</DG2J>
 
							//-- ВРАГ НА ДИСТ.ОГНЯ
							
//<DG2J code_mark="n106:ACTION" >
Settings.SIT_ENEMY_ON_FIRE_DISTANCE
//</DG2J>
 
						} else {
							//-- Враг РЯДОМ?
							if(
//<DG2J code_mark="n99:IF" >
ns >= 0.8
//</DG2J>
) {
								//-- ситуация
								
//<DG2J code_mark="n101:ACTION" >
situation =
//</DG2J>
 
								//-- ВРАГ РЯДОМ
								
//<DG2J code_mark="n100:ACTION" >
Settings.SIT_ENEMY_CLOSE
//</DG2J>
 
							} else {
								//-- ситуация
								
//<DG2J code_mark="n103:ACTION" >
situation =
//</DG2J>
 
								//-- ОПРЕДЕЛЕНА ОШИБОЧНО
								
//<DG2J code_mark="n102:ACTION" >
Settings.SIT_ERROR_DETEСTION;
//</DG2J>
 
								//-- //--         
								
//<DG2J code_mark="n762:SH_END" >
}
//</DG2J>

							}
							//-- Тип ПЛ?
							if(
//<DG2J code_mark="n117:IF" >
target.ship is Sub
//</DG2J>
) {
								//-- тип врага
								
//<DG2J code_mark="n119:ACTION" >
enemy_ship_type =
//</DG2J>
 
								//-- ПЛ
								
//<DG2J code_mark="n118:ACTION" >
Settings.EST_SUB;
//</DG2J>
 
							} else {
								//-- тип врага
								
//<DG2J code_mark="n121:ACTION" >
enemy_ship_type =
//</DG2J>
 
								//-- НАДВОДНЫЙ
								
//<DG2J code_mark="n120:ACTION" >
Settings.EST_SHIP;
//</DG2J>
 
							}
						}
						//-- Тип ПЛ?
						if(
//<DG2J code_mark="n117:IF" >
target.ship is Sub
//</DG2J>
) {
							//-- тип врага
							
//<DG2J code_mark="n119:ACTION" >
enemy_ship_type =
//</DG2J>
 
							//-- ПЛ
							
//<DG2J code_mark="n118:ACTION" >
Settings.EST_SUB;
//</DG2J>
 
						} else {
							//-- тип врага
							
//<DG2J code_mark="n121:ACTION" >
enemy_ship_type =
//</DG2J>
 
							//-- НАДВОДНЫЙ
							
//<DG2J code_mark="n120:ACTION" >
Settings.EST_SHIP;
//</DG2J>
 
						}
					}
					//-- Есть сохраненные данные по цели?
					if(
//<DG2J code_mark="n122:IF" >
mem_dist != -1
//</DG2J>
) {
						//-- расстояние уменьшилось?
						if(
//<DG2J code_mark="n124:IF" >
dist < mem_dist
//</DG2J>
) {
							//-- изменение дистанции
							
//<DG2J code_mark="n126:ACTION" >
enemy_dist_change =
//</DG2J>
 
							//-- УМЕНЬШИЛОСЬ
							
//<DG2J code_mark="n125:ACTION" >
Settings.DC_DECREASE;
//</DG2J>
 
						} else {
							//-- расстояние увеличилось?
							if(
//<DG2J code_mark="n129:IF" >
dist > mem_dist
//</DG2J>
) {
								//-- изменение дистанции
								
//<DG2J code_mark="n128:ACTION" >
enemy_dist_change =
//</DG2J>
 
								//-- УВЕЛИЧИЛОСЬ
								
//<DG2J code_mark="n127:ACTION" >
Settings.DC_INCREASE;
//</DG2J>
 
							} else {
								//-- изменение дистанции
								
//<DG2J code_mark="n131:ACTION" >
enemy_dist_change =
//</DG2J>
 
								//-- НЕ ИЗМЕНИЛОСЬ
								
//<DG2J code_mark="n130:ACTION" >
Settings.DC_NOT_CHANGE;
//</DG2J>
 
							}
						}
					} else {
						//-- изменение дистанции
						
//<DG2J code_mark="n133:ACTION" >
enemy_dist_change =
//</DG2J>
 
						//-- НЕИЗВЕСТНО
						
//<DG2J code_mark="n132:ACTION" >
Settings.DC_UNKNOWN;
//</DG2J>
 
					}
					//-- запоминаем данные цели
					
//<DG2J code_mark="n123:ACTION" >
mem_dist = dist;
//</DG2J>
 
				} else {
					//-- изменение дистанции
					
//<DG2J code_mark="n144:ACTION" >
enemy_dist_change =
//</DG2J>
 
					//-- НЕОПРЕДЕЛЕНО
					
//<DG2J code_mark="n143:ACTION" >
Settings.DC_UNKNOWN;
//</DG2J>
 
				}
			} else {
				//-- ситуация
				
//<DG2J code_mark="n111:ACTION" >
situation =
//</DG2J>
 
				//-- ВРАГ НЕ ОБНАРУЖЕН
				
//<DG2J code_mark="n110:ACTION" >
Settings.SIT_NOENEMY;
//</DG2J>
 
				//-- тип врага
				
//<DG2J code_mark="n142:ACTION" >
enemy_ship_type =
//</DG2J>
 
				//-- НЕ ОПРЕДЕЛЕН
				
//<DG2J code_mark="n141:ACTION" >
Settings.EST_UNKNOWN;
//</DG2J>
 
				//-- изменение дистанции
				
//<DG2J code_mark="n146:ACTION" >
enemy_dist_change =
//</DG2J>
 
				//-- НЕОПРЕДЕЛЕНО
				
//<DG2J code_mark="n145:ACTION" >
Settings.DC_UNKNOWN;
//</DG2J>
 
			}
		}
		//-- //--         
		
//<DG2J code_mark="n761:SH_END" >
}
//</DG2J>

	//-- copy()
	
//<DG2J code_mark="n425:SH_BEG" >
	public function copy(sit:Situation1x1):void { 

//</DG2J>
 
		//-- строим код
		
//<DG2J code_mark="n426:ACTION" >
		situation = sit.situation;
		enemy_ship_type = sit.enemy_ship_type;
		enemy_dist_change = sit.enemy_dist_change;
target = sit.target;
		me = sit.me;
		mem_dist = sit.mem_dist;
		danger_torp = sit.danger_torp;

//</DG2J>
 
		//-- //--             
		
//<DG2J code_mark="n427:SH_END" >
}
//</DG2J>

	//-- getCode()
	
//<DG2J code_mark="n155:SH_BEG" >
public function getCode():String {
//</DG2J>
 
		//-- строим код
		
//<DG2J code_mark="n156:ACTION" >
var ret_code:String = "";
ret_code += " "+situation;
if(target != null && target.ship != null) {
	ret_code += " " + target.ship.getName();
	ret_code += " "+enemy_ship_type;
	ret_code += " " + enemy_dist_change;
}
if (danger_torp != null) {
	ret_code += " " + danger_torp.getName();
}

//</DG2J>
 
		//-- ret_code
		
//<DG2J code_mark="n796:SH_END" >
return ret_code;
}
//</DG2J>

	//-- 
            
	
//<DG2J code_mark="n759:SI_END" >
   } //-- конец класса
} //-- крнец пакета
//</DG2J>
 
