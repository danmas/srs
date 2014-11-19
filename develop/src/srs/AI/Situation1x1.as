
//-- Класс Ситуация 1x1
//
//-- упоминание о DrakonGen
/**
 * Этот текст сгенерирован программой DrakonGen
 * @author Erv
 */

//-- package//-- imports
package srs.AI
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import srs.ships.Ship;
	import srs.ships.Sub;
	import srs.Settings;
	import srs.ships.Torped;
	import srs.ships.Target;
	
	//-- class Situation1x1
	/**
	 * ...
	 * @author Erv
	 */
	public class Situation1x1
	{
		
		//-- переменные
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
		public function Situation1x1(_me:Ship)
		{
			//-- я
			me = 
				//-- из параметра
				_me;
			//-- враг
			target = 
				//-- null
				null;
			//-- ситуация
			situation = 
				//-- ВРАГ НЕ ОБНАРУЖЕН
				Settings.SIT_NOENEMY;
			//-- тип врага
			enemy_ship_type = 
				//-- НЕ ОПРЕДЕЛЕН
				Settings.EST_UNKNOWN;
			//-- изменение дистанции
			enemy_dist_change = 
				//-- НЕОПРЕДЕЛЕНО
				Settings.DC_UNKNOWN;
			//-- //--         
		}
		
		//-- оценка ситуации
		public function detectSituation():void
		{
			//-- Проверка наличия //-- торпедной атаки
			danger_torp = me.checkTrpAtack();
			//-- есть угроза жизни?
			if (danger_torp != null)
			{
				//-- получаем данные угрозы
				//-- null 
				//-- ситуация
				situation = 
					//-- НАС АТАКУЕТ ТОРПЕДА
					Settings.SIT_UNDER_TRP_ATTACK;
			}
			else
			{
				//-- (AI) Выбор цели 
				target = me.selectTarget();
				
				//-- враг есть?
				if (target != null)
				{
					//-- вычисляем дистанцию до цели
					var dist:Number = 100000000000000;
					target.distance = Point.distance(me.getPosition(), target.ship.getPosition());
					dist = target.distance;
					
					//-- вычисляем шум цели
					var ns:Number = target.ship.calcNoiseAtDist(dist);
					target.noise = ns;
					
					//-- враг виден?
					if (ns >= 0.2)
					{
						//-- враг ОБНАРУЖЕН?
						if (ns >= 0.2 && ns < 0.5)
						{
							//-- ситуация
							situation = 
								//-- ВРАГ ОБНАРУЖЕН
								Settings.SIT_ENEMY_DETECTED
							//-- тип врага
							enemy_ship_type = 
								//-- НЕ ОПРЕДЕЛЕН
								Settings.EST_UNKNOWN;
						}
						else
						{
							//-- Враг НА ДИСТ.ОГНЯ?
							if (ns >= 0.5 && ns < 0.8)
							{
								//-- ситуация
								situation = 
									//-- ВРАГ НА ДИСТ.ОГНЯ
									Settings.SIT_ENEMY_ON_FIRE_DISTANCE
							}
							else
							{
								//-- Враг РЯДОМ?
								if (ns >= 0.8)
								{
									//-- ситуация
									situation = 
										//-- ВРАГ РЯДОМ
										Settings.SIT_ENEMY_CLOSE
								}
								else
								{
									//-- ситуация
									situation = 
										//-- ОПРЕДЕЛЕНА ОШИБОЧНО
										Settings.SIT_ERROR_DETEСTION;
									//-- //--         
									return;
								}
							}
							//-- Тип ПЛ?
							if (target.ship is Sub)
							{
								//-- тип врага
								enemy_ship_type = 
									//-- ПЛ
									Settings.EST_SUB;
							}
							else
							{
								//-- тип врага
								enemy_ship_type = 
									//-- НАДВОДНЫЙ
									Settings.EST_SHIP;
							}
						}
						//-- Есть сохраненные данные по цели?
						if (mem_dist != -1)
						{
							//-- расстояние уменьшилось?
							if (dist < mem_dist)
							{
								//-- изменение дистанции
								enemy_dist_change = 
									//-- УМЕНЬШИЛОСЬ
									Settings.DC_DECREASE;
							}
							else
							{
								//-- расстояние увеличилось?
								if (dist > mem_dist)
								{
									//-- изменение дистанции
									enemy_dist_change = 
										//-- УВЕЛИЧИЛОСЬ
										Settings.DC_INCREASE;
								}
								else
								{
									//-- изменение дистанции
									enemy_dist_change = 
										//-- НЕ ИЗМЕНИЛОСЬ
										Settings.DC_NOT_CHANGE;
								}
							}
						}
						else
						{
							//-- изменение дистанции
							enemy_dist_change = 
								//-- НЕИЗВЕСТНО
								Settings.DC_UNKNOWN;
						}
						//-- запоминаем данные цели
						mem_dist = dist;
					}
					else
					{
						//-- изменение дистанции
						enemy_dist_change = 
							//-- НЕОПРЕДЕЛЕНО
							Settings.DC_UNKNOWN;
					}
				}
				else
				{
					//-- ситуация
					situation = 
						//-- ВРАГ НЕ ОБНАРУЖЕН
						Settings.SIT_NOENEMY;
					//-- тип врага
					enemy_ship_type = 
						//-- НЕ ОПРЕДЕЛЕН
						Settings.EST_UNKNOWN;
					//-- изменение дистанции
					enemy_dist_change = 
						//-- НЕОПРЕДЕЛЕНО
						Settings.DC_UNKNOWN;
				}
			}
			//-- //--         
		}
		
		//-- copy()
		public function copy(sit:Situation1x1):void
		{
			
			//-- строим код
			situation = sit.situation;
			enemy_ship_type = sit.enemy_ship_type;
			enemy_dist_change = sit.enemy_dist_change;
			target = sit.target;
			me = sit.me;
			mem_dist = sit.mem_dist;
			danger_torp = sit.danger_torp;
		
			//-- //--             
		}
		
		//-- getCode()
		public function getCode():String
		{
			//-- строим код
			var ret_code:String = "";
			ret_code += " " + situation;
			if (target != null && target.ship != null)
			{
				ret_code += " " + target.ship.getName();
				ret_code += " " + enemy_ship_type;
				ret_code += " " + enemy_dist_change;
			}
			if (danger_torp != null)
			{
				ret_code += " " + danger_torp.getName();
			}
			
			//-- ret_code
			return ret_code;
		}
		//-- 
	
	} //-- конец класса
} //-- крнец пакета 
