
//-- Класс Ситуация 1x1

	
	 //--упоминание о DrakonGen
	   /**
	    * Этот текст сгенерирован программой DrakonGen
	    * @author Erv
	    */
	
	 //--package
	//-- imports
	package  srs.AI
	{
	   import flash.display.Sprite;
	   import flash.geom.Point;
	   import srs.ships.Ship;
	   import srs.ships.Sub;
	   import srs.Settings;
	   import srs.ships.Torped;
	   import srs.ships.Target;
	
	 //--class Situation1x1
	   /**
	    * ...
	    * @author Erv
	    */
	   public class Situation1x1 {
	
	
	 //--переменные
	public var situation:String = Settings.SIT_NOENEMY;
	public var enemy_ship_type:String = Settings.EST_UNKNOWN;
	
	public var enemy_dist_change:String = Settings.DC_UNKNOWN;
	//public var enemy:Ship;
	public var target:Target = null;
	
	public var me:Ship;
	protected var mem_dist:Number = -1;
	
	//-- угрожающая торпеда
	public var danger_torp:Torped;
	
	
	//-- Situation1x1()
	public function Situation1x1(_me:Ship) { 
		//-- я = из параметра
		me =_me;
		//-- враг = null
		target =null;
		//-- ситуация = ВРАГ НЕ ОБНАРУЖЕН
		situation =Settings.SIT_NOENEMY;
		//-- тип врага = НЕ ОПРЕДЕЛЕН
		enemy_ship_type =Settings.EST_UNKNOWN;
		//-- изменение дистанции = НЕОПРЕДЕЛЕНО
		enemy_dist_change =Settings.DC_UNKNOWN;
		//-- выход
		return;
		
	} //-- конец процедуры
	//-- оценка ситуации
	public function detectSituation():void { 
		 //--
		//--       Проверка наличия 
		//-- торпедной атаки
		//--       
		danger_torp = me.checkTrpAtack();
		//-- есть угроза жизни?
		if(danger_torp != null) {
			 //--получаем данные угрозы
			//-- null
			//-- ситуация = НАС АТАКУЕТ ТОРПЕДА
			situation =Settings.SIT_UNDER_TRP_ATTACK;
		} else {
			 //--
			//--       (AI) Выбор цели
			//--       
			target = me.selectTarget();
			
			
			//-- враг есть?
			if(target != null) {
				 //--вычисляем дистанцию до цели
				var dist:Number = 100000000000000;
				target.distance = Point.distance(me.getPosition(), target.ship.getPosition());
				dist = target.distance;
					
				
				 //--вычисляем шум цели
				var ns:Number = target.ship.calcNoiseAtDist(dist);
							target.noise = ns;
				
				//-- враг виден?
				if(ns >= 0.2) {
					//-- враг ОБНАРУЖЕН?
					if(ns >= 0.2 && ns < 0.5) {
						//-- ситуация = ВРАГ ОБНАРУЖЕН
						situation =Settings.SIT_ENEMY_DETECTED
						//-- тип врага = НЕ ОПРЕДЕЛЕН
						enemy_ship_type =Settings.EST_UNKNOWN;
					} else {
						//-- Враг НА ДИСТ.ОГНЯ?
						if(ns >= 0.5 && ns < 0.8) {
							//-- ситуация = ВРАГ НА ДИСТ.ОГНЯ
							situation =Settings.SIT_ENEMY_ON_FIRE_DISTANCE
						} else {
							//-- Враг РЯДОМ?
							if(ns >= 0.8) {
								//-- ситуация = ВРАГ РЯДОМ
								situation =Settings.SIT_ENEMY_CLOSE
							} else {
								//-- ситуация = ОПРЕДЕЛЕНА ОШИБОЧНО
								situation =Settings.SIT_ERROR_DETEСTION;
								//-- выход
								return;
							}
							//-- Тип ПЛ?
							if(target.ship is Sub) {
								//-- тип врага = ПЛ
								enemy_ship_type =Settings.EST_SUB;
							} else {
								//-- тип врага = НАДВОДНЫЙ
								enemy_ship_type =Settings.EST_SHIP;
							}
						}
						//-- Тип ПЛ?
						if(target.ship is Sub) {
							//-- тип врага = ПЛ
							enemy_ship_type =Settings.EST_SUB;
						} else {
							//-- тип врага = НАДВОДНЫЙ
							enemy_ship_type =Settings.EST_SHIP;
						}
					}
					//-- Есть сохраненные данные по цели?
					if(mem_dist != -1) {
						//-- расстояние уменьшилось?
						if(dist < mem_dist) {
							//-- изменение дистанции = УМЕНЬШИЛОСЬ
							enemy_dist_change =Settings.DC_DECREASE;
						} else {
							//-- расстояние увеличилось?
							if(dist > mem_dist) {
								//-- изменение дистанции = УВЕЛИЧИЛОСЬ
								enemy_dist_change =Settings.DC_INCREASE;
							} else {
								//-- изменение дистанции = НЕ ИЗМЕНИЛОСЬ
								enemy_dist_change =Settings.DC_NOT_CHANGE;
							}
						}
					} else {
						//-- изменение дистанции = НЕИЗВЕСТНО
						enemy_dist_change =Settings.DC_UNKNOWN;
					}
					 //--запоминаем данные цели
					mem_dist = dist;
				} else {
					//-- изменение дистанции = НЕОПРЕДЕЛЕНО
					enemy_dist_change =Settings.DC_UNKNOWN;
				}
			} else {
				//-- ситуация = ВРАГ НЕ ОБНАРУЖЕН
				situation =Settings.SIT_NOENEMY;
				//-- тип врага = НЕ ОПРЕДЕЛЕН
				enemy_ship_type =Settings.EST_UNKNOWN;
				//-- изменение дистанции = НЕОПРЕДЕЛЕНО
				enemy_dist_change =Settings.DC_UNKNOWN;
			}
		}
		//-- выход
		return;
	} //-- конец процедуры
	//-- copy()
		public function copy(sit:Situation1x1):void { 
 
		 //--строим код
				situation = sit.situation;
				enemy_ship_type = sit.enemy_ship_type;
				enemy_dist_change = sit.enemy_dist_change;
		target = sit.target;
				me = sit.me;
				mem_dist = sit.mem_dist;
				danger_torp = sit.danger_torp;
		
		//-- 
		//--       
	} //-- конец процедуры
	//-- getCode()
	public function getCode():String { 
		 //--строим код
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
		
		//-- 
		//--       
		return ret_code;
	} //-- конец процедуры
	//-- Выход
		//-- конец
		   } //-- конец класса
		} //-- крнец пакета
