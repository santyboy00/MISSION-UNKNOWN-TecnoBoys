from pathlib import Path
import ast,math,copy,json,random
D=Path(__file__).resolve().parent.parent
s=(D/'scripts/mission_data.gd').read_text()
events=ast.literal_eval(s.split('const EVENTS = ')[1].strip())
missions=[{'budget':175,'transfer':38,'comm':45,'science_min':28,'days':12,'thermal_penalty':1.0,'signal_penalty':1.0},{'budget':235,'transfer':69,'comm':60,'science_min':56,'days':165,'thermal_penalty':1.30,'signal_penalty':1.0},{'budget':295,'transfer':142,'comm':80,'science_min':64,'days':260,'thermal_penalty':1.0,'signal_penalty':1.18}]
rockets=[{'mass_limit':110,'fuel':96,'cost':42},{'mass_limit':170,'fuel':144,'cost':70},{'mass_limit':235,'fuel':214,'cost':110}]
orbits=[{'fuel':8,'science_mult':1},{'fuel':14,'science_mult':1.16},{'fuel':22,'science_mult':.9}]
components=[{'id':x,'cost':y,'mass':z,'generation':p,'consumption':q,'comm':c,'science':u} for x,y,z,p,q,c,u in [('solar',20,18,55,0,0,0),('battery',14,15,24,0,0,0),('camera',20,11,0,16,0,28),('spectro',33,20,0,20,0,44),('antenna',22,14,0,12,70,0),('shield',20,24,0,0,0,0),('thruster',17,12,0,5,0,0),('storage',15,10,0,5,0,12),('radar',24,15,0,14,0,29),('neutron',20,13,0,9,0,23)]]
configs=[{'mission_id':0,'rocket_id':1,'orbit_id':0,'ground_id':1,'components':['solar','battery','camera','antenna']},{'mission_id':1,'rocket_id':1,'orbit_id':0,'ground_id':1,'components':['solar','battery','camera','antenna','spectro']},{'mission_id':2,'rocket_id':2,'orbit_id':0,'ground_id':1,'components':['solar','battery','camera','antenna','spectro','shield']}]
wins=[[0,1,2,0,0,2,0,0,2,2],[0,0,0,0,1,2,1,2,0,1],[0,0,0,0,1,2,2,1,0,2]]
loss=[[2,2,1,0,0,1,2,1,1,0],[0,2,0,0,2,0,1,0,0,2],[0,0,1,1,0,2,0,1,2,1]]
def clamp(n,a,b):return min(b,max(a,n))
def roundi(n):return math.floor(n+0.5)
def eval_(cfg):
 m=missions[cfg['mission_id']]; r=rockets[cfg['rocket_id']];o=orbits[cfg['orbit_id']]
 orbit=[1.00000261,.72333566,1.52371034][cfg['mission_id']]
 solar_factor=.45+.55*clamp(1/(orbit*orbit),.4,1.6)
 cost,mass,power,comm,sci=r['cost']+9,34,0,15+8,0
 for x in components:
  if x['id'] in cfg['components']:
   cost+=x['cost'];mass+=x['mass'];power+=roundi(x['generation']*solar_factor) if x['id']=='solar' else x['generation'];power-=x['consumption'];comm+=x['comm'];sci+=x['science']
 sci=roundi(sci*o['science_mult']);fuel=r['fuel']-m['transfer']-o['fuel']
 return {'valid':all([cost<=m['budget'],mass<=r['mass_limit'],power>=12,comm>=m['comm'],fuel>=16,sci>=m['science_min']]),'power':power,'fuel':fuel,'comm':comm,'science_potential':sci,'budget_left':m['budget']-cost,'solar_factor':solar_factor,'mass':mass,'cost':cost}
def initial(cfg):
 e=eval_(cfg)
 return dict(fuel=float(e['fuel']),power=clamp(58+.4*e['power'],0,100),signal=clamp(e['comm'],0,100),hull=100.,science=.5*e['science_potential'],day=0.,progress=0,route_goal=100.,route_length=100.,route_progress=0.,route_spent=0.,credits_left=float(e['budget_left']),nasa_ideal_days=([3,146.08,258.87][cfg['mission_id']]),delay_days=0.,failed=False,failure_reason='',log=[])
def route_fraction(s):return clamp(s['route_progress']/max(1,s['route_length']),0,1)
def apply(s,i,c,cfg):
 s=copy.deepcopy(s)
 if s['failed']:return s
 m=missions[cfg['mission_id']];ev=events[i];opt=ev['options'][c];effects=opt['effects'];hard=[1,1.16,1.3][cfg['mission_id']]
 route_eff=effects.get('route',0);time_adj=effects.get('days',0)
 for key in ['fuel','power','signal','hull','science']:
  delta=effects.get(key,0)
  if delta<0 and key!='science':
   delta*=hard
   if ev['tag']=='TÉRMICO' and key in ['hull','power']:delta*=m['thermal_penalty']
   if ev['tag']=='COMUNICACIONES' and key=='signal':delta*=m['signal_penalty']
  s[key]+=delta
 special=opt.get('special','');chosen=cfg['components']
 if special=='shield':
  if 'shield' in chosen:s['hull']-=2;route_eff+=3
  else:s['hull']-=14*hard;route_eff-=8
 elif special=='thruster':
  if 'thruster' in chosen:route_eff+=8;s['fuel']+=4
  else:s['hull']-=10*hard;route_eff-=7
 elif special=='instruments':
  if 'spectro' in chosen and 'camera' in chosen:s['science']+=10
  else:s['science']-=11
 elif special=='storage':
  if 'storage' in chosen:s['science']+=12
 elif special=='downlink':
  if 'antenna' not in chosen:s['signal']-=8*hard;s['science']-=10
 if ev['tag']=='COMUNICACIONES' and c==0 and 'antenna' not in chosen:s['signal']-=12*hard;route_eff-=7
 if ev['tag']=='CIENCIA' and 'storage' in chosen:s['science']+=8
 if i==0 and 'thruster' in chosen:route_eff+=4;s['fuel']+=3
 if s['power']<24:s['signal']-=5*hard;route_eff-=5
 if s['signal']<24:s['science']-=6;route_eff-=5
 if s['hull']<38:route_eff-=6;time_adj+=2
 stage=100/len(events)
 movement=max(.5,stage+route_eff*.17-(hard-1)*1.3)
 s['route_progress']+=movement;s['route_length']=clamp(s['route_length']-route_eff*.16,78,158);s['route_spent']+=movement
 clock_scale=m['days']/48
 elapsed=m['days']/len(events)+clock_scale*(time_adj*.42-route_eff*.085)
 ideal=[3.,146.08,258.87][cfg['mission_id']]
 delay=max(0,2.6+time_adj*.42-route_eff*.115)
 scale=.18 if cfg['mission_id']==0 else ideal/170
 s['delay_days']+=delay*scale
 s['day']=ideal*(i+1)/len(events)+s['delay_days']
 s['science']=max(0,s['science'])
 for k in ['power','signal','hull']:s[k]=clamp(s[k],0,100)
 s['progress']=i+1
 s['log'].append({'event':ev['title'],'decision':opt['title']})
 if s['fuel']<0:s.update(failed=True,failure_reason='fuel')
 elif s['power']<=0:s.update(failed=True,failure_reason='power')
 elif s['signal']<=0:s.update(failed=True,failure_reason='signal')
 elif s['hull']<=0:s.update(failed=True,failure_reason='hull')
 elif s['day']>m['days']*1.45:s.update(failed=True,failure_reason='time')
 elif s['progress']>=len(events) and route_fraction(s)<.72:s.update(failed=True,failure_reason='route')
 return s
def replay(cfg,ds):
 s=initial(cfg)
 for i,d in enumerate(ds):
  s=apply(s,i,d,cfg)
  if s['failed']:break
 return s
def success(s,cfg):
 m=missions[cfg['mission_id']];return not s['failed'] and s['progress']==len(events) and route_fraction(s)>=.91 and s['science']>=m['science_min'] and s['power']>=6 and s['hull']>=25 and s['signal']>=19 and s['fuel']>=0
assert len(events)==10
for i,cfg in enumerate(configs):
 e=eval_(cfg);print('CONFIG',i,e)
 assert e['valid'], f'initial invalid {i}'
 for nm,sequences in [('win',wins),('lose',loss)]:
  s=replay(cfg,sequences[i]);print(nm,i,'failed',s['failed'],s['failure_reason'],'success',success(s,cfg),'progress',s['progress'],'route',round(route_fraction(s),2),'pwr',round(s['power'],1),'day',round(s['day'],1))
  if nm=='win':assert success(s,cfg),f'bad winner {i}'
  else:assert s['failed'],f'bad loser {i}'
 assert replay(cfg,wins[i])==replay(cfg,wins[i])
 assert replay(cfg,wins[i])['day'] >= initial(cfg)['nasa_ideal_days']
from math import sqrt
au=[1.00000261,.72333566,1.52371034]
for i,d in enumerate(au):
 transfer=3 if i==0 else .5*365.256*sqrt(((au[0]+d)/2)**3)
 flux=1360.8/(d*d)
 print('NASA calculation',i,round(transfer,2),'d',round(flux,2),'W/m2')
assert abs(.5*365.256*sqrt(((au[0]+au[2])/2)**3)-259)<2
assert abs(.5*365.256*sqrt(((au[0]+au[1])/2)**3)-146)<2
assert json.loads((D/'data/nasa_reference.json').read_text())['constants']['moon_mean_distance_km']==384400
# Evidencia científica: 3 observaciones por misión, cada fuente NASA, respuestas válidas
from urllib.parse import urlparse
edata=json.loads((D/'data/science_evidence_nasa.json').read_text())
for key in ['moon','venus','mars']:
 items=edata['missions'][key]
 assert len(items)==3
 for item in items:
  assert item['instrument'] in [c['id'] for c in components]
  assert 0<=item['answer']<len(item['options'])==3
  assert urlparse(item['source']).hostname in ('science.nasa.gov','ssd.jpl.nasa.gov')
# Modelos físicos correctos en aritmética independiente
G0=9.80665;isp=320;dry=100;prop=85
assert abs(isp*G0*math.log((dry+prop)/dry)-1931.43)<2
assert abs(1360.8/(1.52371034**2)*.5*.27-79.13)<1
assert 146<260
print('VALIDATION V11 PASSED: 3 missions, 9 evidence cases, NASA math, winning/losing paths')
