using System;

namespace Serpen.Diablo
{
    public class Character
    {
        public byte[] Buffer;
        public Character(byte[] buffer)
        {
            Buffer = buffer;
        }

        public string Name
        {
            get
            {
                string name = System.Text.Encoding.ASCII.GetString(Buffer, 321, 32);
                int pos = name.IndexOf((char)0);
                if (pos > 0)
                    return name.Substring(0,pos);
                else
                    return name;
            }
        }

        public eCharClass Class
        {
            get
            {
                return (eCharClass)Buffer[353];
            }
        }

        public override string ToString()
        {
            return System.String.Format("{0} [Level {1} {2}]", Name, Level, Class);
        }

        public int StrengthBase { get { return BitConverter.ToInt32(Buffer, 361); } }
        public int Strength { get { return BitConverter.ToInt32(Buffer, 357); } }

        public int MagicBase { get { return BitConverter.ToInt32(Buffer, 369); } }
        public int Magic { get { return BitConverter.ToInt32(Buffer, 365); } }

        public int DexterityBase { get { return BitConverter.ToInt32(Buffer, 377); } }
        public int Dexterity { get { return BitConverter.ToInt32(Buffer, 373); } }

        public int VitalityBase { get { return BitConverter.ToInt32(Buffer, 385); } }
        public int Vitality { get { return BitConverter.ToInt32(Buffer, 381); } }

        public int Experience { get { return BitConverter.ToInt32(Buffer, 445); } }
        public int ExperienceNext { get { return BitConverter.ToInt32(Buffer, 453); } }

        public int LevelupPoints { get { return BitConverter.ToInt32(Buffer, 389); } }
        public int Level { get { return Buffer[441]; } }
        public int Gold { get { return BitConverter.ToInt32(Buffer, 461); } }
        public int LightRadius { get { return Buffer[319]*10; } }
        public int Dungeon { get { return Buffer[0x35]; } }
        public int PosX { get { return Buffer[0x39]; } }
        public int PosY { get { return Buffer[0x3d]; } }
        // public int GotoPosX { get { return Buffer[0x59]; } }
        // public int GotoPosY { get { return Buffer[0x5d]; } }
        public Direction Dir { get { return (Direction)Buffer[0x71]; } }
        public PLR_MODE Mode { get { return (PLR_MODE)Buffer[0]; } }
    }
}