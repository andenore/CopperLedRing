'use strict';
// Public-CLI acceptance subset. Does not replace the retained legacy/electrical/native checks.
const {test}=require('node:test'),assert=require('node:assert/strict');
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const root=path.resolve(__dirname,'..'),binary=process.env.COPPER_TEST_BIN||'copper';
function compile(source){
 const build=path.join(root,'build');fs.mkdirSync(build,{recursive:true});
 const dir=fs.mkdtempSync(path.join(build,'cli-test-')),out=path.join(dir,'board.json');
 try{const p=cp.spawnSync(binary,['compile',source,'--locked','--offline','-o',out],{cwd:root,encoding:'utf8',timeout:60000,windowsHide:true});
  assert.ifError(p.error);assert.equal(p.status,0,p.stdout+p.stderr);
  const b=JSON.parse(fs.readFileSync(out,'utf8'));assert.equal(b.schema,'copperscript-ir/v0.1');return b;
 }finally{if(!path.resolve(dir).startsWith(path.resolve(build)+path.sep))throw Error('Unsafe test cleanup');fs.rmSync(dir,{recursive:true,force:true});}
}
const nets=b=>Object.fromEntries(b.nets.map(n=>[n.name,new Set(n.endpoints)]));
test('twelve independently controlled LED cathodes and series resistors',()=>{
 const b=compile('board.copper'),n=nets(b),controls=new Set();
 for(let i=1;i<=12;i++){
  assert.deepEqual(n['LED'+i+'_A'],new Set(['R_LED'+i+'.2','LED'+i+'.A']));
  const k=[...n['LED'+i+'_K']];assert.ok(k.includes('LED'+i+'.K'));
  const control=k.find(p=>p.startsWith('U1.'));assert.ok(control);controls.add(control);
 }assert.equal(controls.size,12);
});
