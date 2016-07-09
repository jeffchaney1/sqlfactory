using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    
    //public sealed class DataType
    //{
    //    #region basicfunctionality
    //    public string Name { get; private set;}
    //    public int Ordinal { get; private set;}

    //    public override String ToString()
    //    {
    //        return this.Name;
    //    }

    //    public bool Equals(String name)
    //    {
    //        if (name == null)
    //        {
    //            return false;
    //        }
    //        else
    //        {
    //            return this.Name.ToUpper().Equals(name.ToUpper());
    //        }
    //    }
    //    public bool Equals(int? ordinal)
    //    {
    //        if (ordinal.HasValue)
    //        {
    //            return this.Ordinal == ordinal.Value;
    //        }
    //        else
    //            return false;
    //    }

    //    public bool Equals(DataType other)
    //    {
    //        if (other == null)
    //        {
    //            return false;
    //        }
    //        else
    //        {
    //            return this.Ordinal == other.Ordinal;
    //        }
    //    }

    //    public override bool Equals(Object other)
    //    {
    //        if ((other == null) || !(other is DataType)) 
    //        {
    //            return false;
    //        }
    //        else
    //        {
    //            return Equals((DataType)other);
    //        }
    //    }
        
    //    public override int GetHashCode()
    //    {
    //        return this.Ordinal;
    //    }
        
    //    public static bool TryParse(String name, out DataType result) 
    //    {

    //        if ((name != null) && (byName.ContainsKey(name.ToUpper())))
    //        {
    //            result = byName[name.ToUpper()];
    //            return true;
    //        }
    //        else
    //        {
    //            result = null;
    //            return false;
    //        }
    //    }

    //    public static DataType Parse(String name)
    //    {
    //        DataType result = null;
    //        if ((name != null) && (TryParse(name, out result)))
    //            return result;
    //        else
    //            throw new Exception("Invalid DataType, " + (name==null?"(null)":"'" + name + "'"));
    //    }

    //    public static bool TryFromOrdinal(int ordinal, out DataType result)
    //    {
    //        if (byOrdinal.ContainsKey(ordinal))
    //        {
    //            result = byOrdinal[ordinal];
    //            return true;
    //        }
    //        else
    //        {
    //            result = null;
    //            return false;
    //        }
    //    }

    //    public static DataType FromOrdinal(int ordinal)
    //    {
    //        DataType result = null;
    //        if (TryFromOrdinal(ordinal, out result))
    //        {
    //            return result;
    //        }
    //        else
    //            throw new Exception("Invalid DataType ordinal, " + ordinal);
    //    }
    //    #endregion
        
    //    #region plumbing
    //    private static int lastOrd = -1;
    //    private static List<DataType> allElements = new List<DataType>();
    //    private static Dictionary<Int32, DataType> byOrdinal = new Dictionary<Int32, DataType>();
    //    private static Dictionary<String, DataType> byName = new Dictionary<String, DataType>();

    //    private DataType(string name, int? ordinal = null)
    //    {
    //        if (!ordinal.HasValue)
    //        {
    //           this.Ordinal = lastOrd + 1;
    //        }
    //        else if (byOrdinal.Keys.Contains(ordinal.Value))
    //        {
    //            throw new Exception("DataType already contains Ordinal of " + ordinal.Value);
    //        }
    //        else {
    //            this.Ordinal = ordinal.Value;
    //        }

    //        if (this.Ordinal > lastOrd) {
    //            lastOrd = this.Ordinal;
    //        }
            
    //        if (name == null) {
    //            name = Convert.ToString(this.Ordinal);
    //        }
            
    //        if (byName.Keys.Contains(name.ToUpper())) {
    //            throw new Exception("DataType already contains value, '" + name + "'");
    //        }
            
    //        this.Name = name;

    //        allElements.Add(this);
    //        byName.Add(this.Name.ToUpper(), this);
    //        byOrdinal.Add(this.Ordinal, this);
    //    }
    //    #endregion


    //    public static readonly DataType dtString = new DataType("dtString");
    //    public static readonly DataType dtInteger = new DataType("dtInteger");
    //    public static readonly DataType dtBoolean = new DataType("dtBoolean");
    //    public static readonly DataType dtDateTime = new DataType("dtDateTime");
    //    public static readonly DataType dtDouble = new DataType("dtDouble");

    //}

}
