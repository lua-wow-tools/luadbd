describe('dbcsig', function()
  local basesig = require('luadbd.sig')
  local getVersion = require('luadbd.build')
  local parse = require('luadbd.parser').dbd

  local function dbcsig(dbd, build)
    local v = getVersion(dbd, build)
    return v and basesig(dbd, v) or nil
  end

  it('returns null if no versions', function()
    local dbd = parse('COLUMNS\n')
    assert.Nil(dbcsig(dbd, '0.0.0.0'))
  end)

  it('matches exact versions', function()
    local dbd = parse([[
COLUMNS
int moocow

BUILD 0.1.2.3
moocow<32>
]])
    assert.Nil(dbcsig(dbd, '0.0.0.0'))
    assert.same('i', dbcsig(dbd, '0.1.2.3'))
  end)

  it('matches version ranges', function()
    local dbd = parse([[
COLUMNS
int moocow

BUILD 0.1.2.3-0.1.2.5
moocow<32>
]])
    assert.Nil(dbcsig(dbd, '0.1.1.3'))
    assert.Nil(dbcsig(dbd, '0.1.2.2'))
    assert.same('i', dbcsig(dbd, '0.1.2.3'))
    assert.same('i', dbcsig(dbd, '0.1.2.4'))
    assert.same('i', dbcsig(dbd, '0.1.2.5'))
    assert.Nil(dbcsig(dbd, '0.1.2.6'))
    assert.Nil(dbcsig(dbd, '0.1.3.3'))
  end)

  it('matches all types', function()
    local dbd = parse([[
COLUMNS
int moocow
string cowmoo
locstring wat
float lol

BUILD 0.1.2.3
$id,noninline$moocow<16>
$relation$moocow<16>
$relation,noninline$moocow<8>
moocow<32>
moocow<64>
moocow<u32>[5]
moocow<u64>
cowmoo
wat
lol
]])
    assert.same('iFiL{5u}Lss.', dbcsig(dbd, '0.1.2.3'))
  end)
end)
