using System;

namespace Serpen.Diablo
{
    class Spell {
        public eSpell Spell { get; set; }
        public byte Index { get; set; }
        public String Spellbook { get; set; }
        public bool Enabled { get; set; }
        public byte Level { get; set; }
    }
}