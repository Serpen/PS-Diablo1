using System;

namespace Serpen.Diablo
{
    public class Item
    {
        public const int SIZE = 0x170;
        private const int ITEMNAMESIZE = 0x40;

        //for debug purpose
        public byte[] buffer = new byte[SIZE];

        int prefix = 0;

        byte[] preambleItmFormat = { 0x49, 0x54, 0x4d, 0x30, 0x31, 0x2e, 0x49, 0x27, 0x6c, 0x6c, 0x20, 0x67, 0x65, 0x74, 0x20, 0x74, 0x68, 0x61, 0x74, 0x20, 0x61, 0x6c, 0x27, 0x54, 0x68, 0x6f, 0x72, 0x21, 0x0, 0x0, 0x0, 0x0 };

        public Item(string path)
        {
            System.IO.FileStream stream = System.IO.File.OpenRead(path);
            byte[] mbuffer = new byte[stream.Length];
            stream.Read(mbuffer, 0, (int)stream.Length);
            stream.Close();

            int i;

            for (i = 0; i < preambleItmFormat.Length; i++)
                if (preambleItmFormat[i] != mbuffer[i])
                    break;

            if (i == preambleItmFormat.Length)
                Array.Copy(mbuffer, i, buffer, 0, mbuffer.Length - i);
            else
                buffer = mbuffer;

            if (buffer.Length != SIZE)
                throw new Exception();
        }

        public Item(byte[] pBuffer)
        {
            int i;

            for (i = 0; i < preambleItmFormat.Length; i++)
                if (preambleItmFormat[i] != pBuffer[i])
                    break;
            if (i == preambleItmFormat.Length)
                Array.Copy(pBuffer, i, buffer, 0, pBuffer.Length - i);
            else
                buffer = pBuffer;

            if (buffer.Length != SIZE)
                throw new Exception();
        }

        private string ConvertDiabloString(int start, int len)
        {
            string erg = System.Text.Encoding.ASCII.GetString(buffer, start, len);
            int pos = erg.IndexOf((char)0);
            if (pos > 0)
                return erg.Substring(0, pos);
            else
                return erg;
        }

        public override string ToString()
        {
            if (ItemClass == eItemType.Gold)
                return string.Format("{0} Gold", BasePrice);
            else
                if (Identified || Quality == eItemQuality.normal)
                return IdentifiedName;
            else
                return string.Format("{0} (not identified)", UnidentifiedName);
        }

        public string UnidentifiedName
        {
            get
            {
                return ConvertDiabloString(0x3d + prefix, ITEMNAMESIZE);
            }
            set
            {
                if (value.Length + 1 > ITEMNAMESIZE)
                    throw new ArgumentOutOfRangeException();
                else
                {
                    byte[] temp = System.Text.Encoding.ASCII.GetBytes(value + (char)0);
                    Array.Copy(temp, 0, buffer, 0x3D, temp.Length);
                }
            }
        }

        public string IdentifiedName
        {
            get
            {
                return ConvertDiabloString(0x7d + prefix, 0x40);
            }
            set
            {
                if (value.Length + 1 > ITEMNAMESIZE)
                    throw new ArgumentOutOfRangeException();
                else
                {
                    byte[] temp = System.Text.Encoding.ASCII.GetBytes(value + (char)0);
                    Array.Copy(temp, 0, buffer, 0x3D, temp.Length);
                }
            }
        }

        public uint ID
        {
            get
            {
                return System.BitConverter.ToUInt32(buffer, prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0, temp.Length);
            }
        }

        public string Found
        {
            get
            {
                UInt16 temp = System.BitConverter.ToUInt16(buffer, 0x4 + prefix);
                if (temp == (temp | 0x10000))
                    return "0x10000 Level ?" + (temp & 63);
                else if (temp == (temp | 0x8000))
                    return "0x8000 Level ?" + (temp & 63);
                else if (temp == (temp | 0x4000))
                    return "Pepin Level" + (temp & 63);
                else if (temp == (temp | 0x2000))
                    return "Adria Level" + (temp & 63);
                else if (temp == (temp | 0x1000))
                    return "Wirt Level " + (temp & 63);
                else if (temp == (temp | 0x800))
                    return "Griswold Premium Level " + (temp & 63);
                else if (temp == (temp | 0x400))
                    return "Griswold Basic Level " + (temp & 63);
                else if (temp == (temp | 0x200))
                    return "Single Player Monster Level " + (temp & 63);
                else if (temp == (temp | 0x100))
                    return "Monster Level " + (temp & 63);
                else if (temp == (temp | 0xc0))
                    return "Unique Monster Level " + (temp & 63);
                else if (temp == (temp | 0x40))
                    return "Dungeon Level " + ((temp & 63) >> 1);
                else
                    return "Unknown Level " + (temp & 63);
            }
        }

        public eItemType ItemClass
        {
            get
            {
                return (eItemType)buffer[0x8 + prefix];
            }
        }

        public bool Identified
        {
            get
            {
                return buffer[0x38 + prefix] == 0 ? false : true;
            }
            set
            {
                buffer[0x38 + prefix] = (byte)(value ? 1 : 0);
            }
        }

        public eItemQuality Quality
        {
            get
            {
                return (eItemQuality)buffer[0x3c + prefix];
            }
        }

        public eEquipType EquipType
        {
            get
            {
                return (eEquipType)buffer[0xBD + prefix];
            }
        }

        public eItemCategory Category
        {
            get
            {
                return (eItemCategory)buffer[0xBE + prefix];
            }
        }

        public uint BasePrice
        {
            get
            {
                return (uint)(System.BitConverter.ToUInt32(buffer, 0xC4 + prefix) / (ItemClass == eItemType.Gold ? 1 : 4));
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value * (ItemClass == eItemType.Gold ? 1 : 4));
                Array.Copy(temp, 0, buffer, 0xC4 + prefix, temp.Length);
            }
        }

        public uint IdentifiedPrice
        {
            get
            {
                return (uint)(System.BitConverter.ToUInt32(buffer, 0xC8 + prefix) / (ItemClass == eItemType.Gold ? 1 : 4));
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value * (ItemClass == eItemType.Gold ? 1 : 4));
                Array.Copy(temp, 0, buffer, 0xC8 + prefix, temp.Length);
            }
        }

        public FromTo Damage
        {
            get
            {
                return new FromTo(
                    BitConverter.ToInt32(buffer, 0xCC + prefix),
                    BitConverter.ToInt32(buffer, 0xD0 + prefix));
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value.From);
                Array.Copy(temp, 0, buffer, 0xCC + prefix, temp.Length);
                temp = System.BitConverter.GetBytes(value.To);
                Array.Copy(temp, 0, buffer, 0xD0 + prefix, temp.Length);
            }
        }

        public int Amor
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0xD4 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0xD4 + prefix, temp.Length);
            }
        }

        public eSpecialEffect SpecialEffect
        {
            get
            {
                return (eSpecialEffect)System.BitConverter.ToUInt32(buffer, 0xD8 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes((uint)value);
                Array.Copy(temp, 0, buffer, 0xD8 + prefix, temp.Length);
            }
        }

        public eItemCode ItemCode
        {
            get
            {
                return (eItemCode)System.BitConverter.ToInt32(buffer, 0xDC + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes((int)value);
                Array.Copy(temp, 0, buffer, 0xD8 + prefix, temp.Length);
            }
        }

        public eSpell Spell
        {
            get
            {
                return (eSpell)System.BitConverter.ToUInt32(buffer, 0xE0 + prefix);
            }
            set
            {
                if (value != eSpell.None)
                    buffer[0xE0 + prefix] = (byte)value;
            }
        }

        public FromTo Charges
        {
            get
            {
                return new FromTo(
                    BitConverter.ToInt32(buffer, 0xE4 + prefix),
                    BitConverter.ToInt32(buffer, 0xE8 + prefix),
                    '/');
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value.From);
                Array.Copy(temp, 0, buffer, 0xE4 + prefix, temp.Length);
                temp = System.BitConverter.GetBytes(value.To);
                Array.Copy(temp, 0, buffer, 0xE8 + prefix, temp.Length);
            }
        }

        public FromTo Durability
        {
            get
            {
                return new FromTo(
                    System.BitConverter.ToInt32(buffer, 0xEC + prefix),
                    System.BitConverter.ToInt32(buffer, 0xF0 + prefix),
                    '/');
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value.From);
                Array.Copy(temp, 0, buffer, 0xEC + prefix, temp.Length);
                temp = System.BitConverter.GetBytes(value.From);
                Array.Copy(temp, 0, buffer, 0xF0 + prefix, temp.Length);
            }
        }

        public int DamageBonus
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0xF4 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0xF4 + prefix, temp.Length);
            }
        }

        public int ChanceToHit
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0xF8 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0xF8 + prefix, temp.Length);
            }
        }

        public int AmorBonus
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0xFc + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0xFC + prefix, temp.Length);
            }
        }

        public void SetAllAttributes(int val)
        {
            StrengthBonus =
            MagicBonus =
            DexterityBonus =
            VitalityBonus = val;
        }

        public int StrengthBonus
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0x100 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x100 + prefix, temp.Length);
            }
        }

        public int MagicBonus
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0x104 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x104 + prefix, temp.Length);
            }
        }

        public int DexterityBonus
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0x108 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x108 + prefix, temp.Length);
            }
        }

        public int VitalityBonus
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0x10c + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x10C + prefix, temp.Length);
            }
        }

        public void SetResistAll(byte val)
        {
            ResistFire = ResistLightning = ResistMagic = val;
        }

        public int ResistFire
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0x110 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x110 + prefix, temp.Length);
            }
        }
        public int ResistLightning
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0x114 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x114 + prefix, temp.Length);
            }
        }
        public int ResistMagic
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0x118 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x118 + prefix, temp.Length);
            }
        }

        public int ManaBonus
        {
            get
            {
                return System.BitConverter.ToUInt16(buffer, 0x11c + prefix) >> 6;
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x11C + prefix, temp.Length);
            }
        }
        public int LifeBonus
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0x120 + prefix) >> 6;
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x120 + prefix, temp.Length);
            }
        }

        public int ExtraDamage
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0x124 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x124 + prefix, temp.Length);
            }
        }
        public int DamageModifier
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0x128 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x128 + prefix, temp.Length);
            }
        }

        public int LightRadius
        {
            get
            {
                return System.BitConverter.ToInt32(buffer, 0x12c + prefix) * 10;
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value / 10);
                Array.Copy(temp, 0, buffer, 0x12C + prefix, temp.Length);
            }
        }

        public byte Spellbonus
        {
            get
            {
                return buffer[0x130 + prefix];
            }
            set
            {
                buffer[0x130 + prefix] = value;
            }
        }

        public eUniqueItem UniqueId
        {
            get
            {
                if (Quality == eItemQuality.unique)
                    return (eUniqueItem)System.BitConverter.ToUInt32(buffer, 0x134 + prefix);
                else
                    return eUniqueItem.NONE;
            }
            set
            {
                if (value != eUniqueItem.NONE && Quality != eItemQuality.unique)
                {
                    byte[] temp = System.BitConverter.GetBytes((uint)value);
                    Array.Copy(temp, 0, buffer, 0x134 + prefix, temp.Length);
                }
            }
        }

        public FromTo FireDamage
        {
            get
            {
                return new FromTo(
                    BitConverter.ToInt32(buffer, 0x138 + prefix),
                    BitConverter.ToInt32(buffer, 0x13c + prefix),
                    '-');
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value.From);
                Array.Copy(temp, 0, buffer, 0x138 + prefix, temp.Length);
                temp = System.BitConverter.GetBytes(value.To);
                Array.Copy(temp, 0, buffer, 0x13C + prefix, temp.Length);
            }
        }

        public FromTo LightningDamage
        {
            get
            {
                return new FromTo(
                    BitConverter.ToInt32(buffer, 0x140 + prefix),
                    BitConverter.ToInt32(buffer, 0x140 + 4 + prefix),
                    '-');
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value.From);
                Array.Copy(temp, 0, buffer, 0x140 + prefix, temp.Length);
                temp = System.BitConverter.GetBytes(value.To);
                Array.Copy(temp, 0, buffer, 0x140 + 4 + prefix, temp.Length);
            }
        }


        public byte RequireStr
        {
            get
            {
                return buffer[0x160 + prefix];
            }
            set
            {
                buffer[0x160 + prefix] = value;
            }
        }
        public byte RequireMagic
        {
            get
            {
                return buffer[0x161 + prefix];
            }
            set
            {
                buffer[0x161 + prefix] = value;
            }
        }
        public byte RequireDex
        {
            get
            {
                return buffer[0x162 + prefix];
            }
            set
            {
                buffer[0x162 + prefix] = value;
            }
        }

        bool Equippable
        {
            get
            {
                return buffer[0x164 + prefix] == 0 ? true : false;
            }
            set
            {
                buffer[0x164 + prefix] = (byte)(value ? 1 : 0);
            }
        }

        public uint inactive
        {
            get
            {
                return System.BitConverter.ToUInt32(buffer, 0x2C + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes(value);
                Array.Copy(temp, 0, buffer, 0x2C + prefix, temp.Length);
            }
        }

        public eItemBase ItemBase
        {
            get
            {
                return (eItemBase)System.BitConverter.ToUInt32(buffer, 0x168 + prefix);
            }
            set
            {
                byte[] temp = System.BitConverter.GetBytes((uint)value);
                Array.Copy(temp, 0, buffer, 0x168 + prefix, temp.Length);
            }
        }

    }
}
