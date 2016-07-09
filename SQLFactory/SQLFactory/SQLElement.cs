using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Library.Collection;

namespace Library.SQLFactory
{
    public abstract class SQLElementItem : ISQLElement, IOwnedItem
    {
        public IOwnedItem Owner { get; set; }

        public virtual Boolean IsMatch(String key){return false;}

        public virtual String AsString()
        {
            return SQLFactory._AsString(this);
        }

        public virtual String Name
        {
            get
            {
                try
                {
                    return this.GetType().Name + ": " + SQLFactory._AsString(this, false);
                }
                catch (Exception) {
                    return "";
                }
            }
        }

        public virtual String BuildSQL(ParameterList parameters = null)
        {
            return SQLFactory._BuildSQL(this, null, parameters, "");
        }

        public abstract void BuildSQL(StringBuilder sql, ParameterList parameters, String indent = "");

    }

    public abstract class SQLElementList<TSQLElementItem> : OwningCollection<TSQLElementItem>, ISQLElement
        where TSQLElementItem : SQLElementItem
    {
        public abstract void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "");

        public virtual string BuildSQL(ParameterList parameters = null)
        {
            return SQLFactory._BuildSQL(this, null, parameters, "");
        }

        public string AsString()
        {
            return SQLFactory._AsString(this, true);
        }

        

        //public void Assign(IOwnedElement Source) {
        //    if ((Source != null) && (Source is SQLElementList)) {
        //        this.Clear();

        //        this.Union(((SQLElementList)Source));
        //    }
        //}

    }

    public abstract class SQLElementParent : ISQLElement
    {
        //private IOwnedElement owner = null;
        //public SQLElementParent(IOwnedElement Owner) 
        //{
        //    this.owner = Owner;
        //}

        public virtual string BuildSQL(ParameterList parameters = null)
        {
            return SQLFactory._BuildSQL(this, null, parameters, "");
        }

        public virtual string AsString()
        {
            return SQLFactory._AsString(this);
        }

        public virtual Boolean IsMatch(String key)
        {
            return false;
        }

        public abstract void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "");
    }

    public abstract class ParameteredElement : SQLElementItem
    {
        private ParameterList parameters = new ParameterList();
        public ParameterList Parameters { 
            get { 
                if (parameters == null) {
                    parameters = new ParameterList();
                }
                return parameters;
            }
            set
            {
                parameters = value;
            }
        }


        public ParameteredElement AddBooleanParameter(bool value)
        {
            parameters.AddBooleanParameter(value);
            return this;
        }

        public ParameteredElement AddIntegerParameter(int value)
        {
            parameters.AddIntegerParameter(value);
            return this;
        }

        public ParameteredElement AddFloatParameter(double value)
        {
            parameters.AddFloatParameter(value);
            return this;
        }

        public ParameteredElement AddStringParameter(string value)
        {
            parameters.AddStringParameter(value);
            return this;
        }

        public ParameteredElement AddDateTimeParameter(DateTime value)
        {
            parameters.AddDateTimeParameter(value);
            return this;
        }

        public ParameteredElement AddParameters(ParameterList source)
        {
            parameters.AddParameters(source);
            return this;
        }

        public ParameteredElement AddParameters(Object[] source)
        {
            foreach (Object parameter in source)
            {
                this.parameters.AddObjectAsParameter(parameter);
            }
            return this;
        }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            InternalBuildParameters(parameters);
        }

        protected virtual void InternalBuildParameters(ParameterList parameters)
        {
            if (parameters != null)
                parameters.AddParameters(this.parameters);
        }

        protected virtual String CleanUp(String str) {
            Boolean inQuotes = false;
            String result = str;
            for(int i=0;i < result.Length;i++) {
                // Question Marks, '?', establish parameters in MSSQL but Delphi
                //   doesn't recognize them.  It needs colons, ':'.
                if (!inQuotes && (result[i] == '?')) {
                    result = result.Substring(0, i-1) + ':' + result.Substring(i+1);
                }
                else if ((result[i] == '"') || (result[i] =="'"[0])) {
                    inQuotes = !inQuotes;
                }
            }
            return result;
        }
    }

}
