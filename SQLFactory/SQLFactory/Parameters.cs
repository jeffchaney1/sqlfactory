using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public enum ParameterDirection { pdInput, pdOutput, pdInputOutput }
    public class Parameter
    {
        public Object Value { get; set; }
        public DataType Type { get; set; }
        public ParameterDirection Direction { get; set; }
        public int Size { get; set; }

        public override string ToString()
        {
            
            if (Type.Equals(DataType.dtString))
            {
                return "'" + Convert.ToString(Value) + "'";
            }
            else if (Type.Equals(DataType.dtDateTime))
            {
                return "'" + String.Format("{0:yyyy-MM-dd HH:mm:ss.FFF}", Convert.ToDateTime(Value)) + "'";
            }
            else if (Type.Equals(DataType.dtBoolean))
            {
                if (Convert.ToBoolean(Value))
                {
                    return "1 /*True*/";
                }
                else
                {
                    return "0 /*False*/";
                }
            }
            else if (Type.Equals(DataType.dtDouble)) {
                return String.Format("{0:##############0\\.0#########", Convert.ToDouble(Value));
            }
            else if (Type.Equals(DataType.dtInteger)) {
                return String.Format("{0:##############0", Convert.ToDouble(Value));
            }
            else {
                return Convert.ToString(Value);
            }

        }
    }

    public class ParameterList : List<Parameter>
    {
        public void AddBooleanParameter(bool value)
        {
            this.Add(new Parameter() { Value = value, Type = DataType.dtBoolean, Size = 1, Direction = ParameterDirection.pdInput });
        }

        public void AddIntegerParameter(int value)
        {
            this.Add(new Parameter() { Value = value, Type = DataType.dtInteger, Size = 4, Direction = ParameterDirection.pdInput });
        }

        public void AddFloatParameter(double value)
        {
            this.Add(new Parameter() { Value = value, Type = DataType.dtDouble, Size = 8, Direction = ParameterDirection.pdInput });
        }

        public void AddStringParameter(string value)
        {
            if (value != null)
            {
                this.Add(new Parameter() { Value = value, Type = DataType.dtString, Size = value.Length, Direction = ParameterDirection.pdInput });
            }
            else
            {
                this.Add(new Parameter() { Value = value, Type = DataType.dtString, Size = 0, Direction = ParameterDirection.pdInput });
            }
        }

        public void AddDateTimeParameter(DateTime value)
        {
            this.Add(new Parameter() { Value = value, Type = DataType.dtDateTime, Size = 8, Direction = ParameterDirection.pdInput });
        }

        public void AddParameter(Parameter parameter) {
            this.Add(new Parameter() { Value = parameter.Value, Type = parameter.Type, Size = parameter.Size, Direction = parameter.Direction});
        }

        public void AddObjectAsParameter(Object obj)
        {
            if (obj == null) {
                this.AddStringParameter(null);
            }
            else if (typeof(Boolean).Equals(obj.GetType())) {
                this.AddBooleanParameter(Convert.ToBoolean(obj));
            }
            try
            {
                try {
                    DateTime dt = Convert.ToDateTime(obj);
                    this.AddDateTimeParameter(dt);
                }
                catch {
                    Double d = Convert.ToDouble(obj);
                    if (d == Math.Floor(d))
                    {
                        this.AddIntegerParameter(Convert.ToInt32(Math.Floor(d)));
                    }
                    else
                    {
                        this.AddFloatParameter(d);
                    }
                }

            }
            catch
            {
                this.AddStringParameter(obj.ToString());
            }
        }

        public void AddParameters(ParameterList source)
        {
            foreach (Parameter item in source)
            {
                AddParameter(item);
            }
        }

        public void AddParameters(Object[] parameters)
        {
            foreach (Object value in parameters)
            {
                AddObjectAsParameter(value);
            }
        }


        public override String ToString()
        {
            StringBuilder buf = new StringBuilder();
            AppendString(buf);
            return buf.ToString();
        }

        public void AppendString(StringBuilder buf) {
            var first = true;
            foreach (Parameter p in this)
            {
                if (!first)
                    buf.Append(',');
                buf.Append(p.ToString());
                first = false;
            }
        }

    }
}
