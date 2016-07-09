using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Enum
{
    public class EnumerationException : Exception
    {
        public EnumerationException(String message)
            : base(message)
        {}
    }

    public class EnumerationValue
    {
        public string Name { get; private set; }
        public int Ordinal { get; private set; }
        public string Code { get; private set; }

        private static int lastOrd = -1;

        protected EnumerationValue(){}

        protected EnumerationValue(String name, int? ordinal, String code)
        {
            if (!ordinal.HasValue)
            {
                ordinal = lastOrd + 1;
            }

            if (String.IsNullOrEmpty(name))
            {
                name = Convert.ToString(ordinal);
            }

            if (String.IsNullOrEmpty(code))
            {
                code = name; 
            }

            this.Ordinal = ordinal.Value;
            this.Name = name.Trim();
            this.Code = code.Trim().ToUpper();

            if (this.Ordinal > lastOrd)
            {
                lastOrd = this.Ordinal;
            }

        }


    }

    public class EnumImpl<EnumType> : EnumerationValue where EnumType : EnumerationValue
    {
        private static List<Object> allElements = new List<Object>();
        private static Dictionary<Int32, Object> byOrdinal = new Dictionary<Int32, Object>();
        private static Dictionary<String, Object> byName = new Dictionary<String, Object>();
        private static Dictionary<String, Object> byCode = new Dictionary<String, Object>();
        private static bool isSealed = false;

        protected static bool Seal()
        {
            bool wasSealed = isSealed;
            isSealed = true;
            return wasSealed;
        }
        protected EnumImpl() :base() { }

        protected EnumImpl(String name, int? ordinal = null, String code = null)
            : base(name, ordinal, code)
        {  
        //}

        //protected static EnumType Add(String name, int? ordinal = null, String code = null)
        //{

            if (isSealed)
            {
                throw new EnumerationException(typeof(EnumType).Name + " is sealed.  No more values can be defined.");
            }

            EnumImpl<EnumType>.Add((EnumType)(Object)this);
            //EnumImpl<EnumType>  newEnum = this; /* (EnumType)Activator.CreateInstance(typeof(EnumType),
            //     new Object[] { ordinal, name, code });*/
        }

        protected static EnumType Add(EnumType newEnum) 
        {
            if (byCode.Keys.Contains(newEnum.Code))
            {
                throw new EnumerationException(typeof(EnumType).Name + " already contains a value with code, '" + newEnum.Code + "'");
            }

            if (byOrdinal.Keys.Contains(newEnum.Ordinal))
            {
                throw new EnumerationException(typeof(EnumType).Name + " already contains a value with Ordinal of " + Convert.ToString(newEnum.Ordinal));
            }

            allElements.Add(newEnum);
            byName.Add(newEnum.Name.ToUpper(), newEnum);
            byOrdinal.Add(newEnum.Ordinal, newEnum);
            byCode.Add(newEnum.Code, newEnum);
            return newEnum;
        }

        public override String ToString()
        {
            return this.Name;
        }

        //public bool Equals(String code)
        //{
        //    if (code == null)
        //    {
        //        return false;
        //    }
        //    else
        //    {
        //    }
        //}
        //public bool Equals(int? ordinal)
        //{
        //    if (ordinal.HasValue)
        //    {
        //        return this.Ordinal == ordinal.Value;
        //    }
        //    else
        //        return false;
        //}

        public override bool Equals(Object otherOp)
        {
            if (otherOp == null) {
                return false;
            }
            else if (this.GetType().Equals(otherOp.GetType()))
            {
                return this.Ordinal == ((EnumerationValue)otherOp).Ordinal;
            }
            else if (typeof(String).Equals(otherOp.GetType() )) {
                return this.Code.Equals(otherOp.ToString().Trim().ToUpper());
            }
            else 
            {
                try {
                    return this.Ordinal == Convert.ToInt32(otherOp);
                }
                catch {
                    return false;
                }
                
            }
        }

        public override int GetHashCode()
        {
            return this.Ordinal;
        }

        public static bool TryFromName(String name, out EnumType result) 
        {

            if (byName.ContainsKey(name.ToUpper()))
            {
                result = (EnumType)byName[name.ToUpper()];
                return true;
            }
            else
            {
                result = null;
                return false;
            }
        }

        public static EnumType FromName(String name)
        {
            EnumType result = null;
            if (TryFromName(name, out result))
                return result;
            else
                throw new Exception("Invalid Name, " + (name == null ? "(null)" : "'" + name + "'" ) + ", for " + typeof(EnumType).Name);
        }

        public static bool TryParseFromCode(String code, out EnumType result)
        {

            if (byCode.ContainsKey(code.Trim().ToUpper()))
            {
                result = (EnumType)byCode[code.Trim().ToUpper()];
                return true;
            }
            else
            {
                result = null;
                return false;
            }
        }

        public static EnumType ParseFromCode(String code)
        {
            EnumType result = null;
            if (TryParseFromCode(code, out result))
                return result;
            else
                throw new Exception("Invalid Code, " + (code == null ? "(null)" : "'" + code.Trim().ToUpper() + "'") + ", for " + typeof(EnumType).Name);
        }


        public static bool TryFromOrdinal(int ordinal, out EnumType result)
        {
            if (byOrdinal.ContainsKey(ordinal))
            {
                result = (EnumType)byOrdinal[ordinal];
                return true;
            }
            else
            {
                result = null;
                return false;
            }
        }

        public static EnumType FromOrdinal(int ordinal)
        {
            EnumType result = null;
            if (TryFromOrdinal(ordinal, out result))
            {
                return result;
            }
            else
                throw new Exception("Invalid Ordinal, " + Convert.ToString(ordinal) + ", for " + typeof(EnumType).Name);
        }


    }

}
