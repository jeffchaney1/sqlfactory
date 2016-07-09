using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class ConditionGroup : Condition
    {
        public ConditionGroup()
        {
            this.Conditions = new ConditionList();
           // this.Conditions.DefaultLink = this.LinkOperator;
        }
        public ConditionList Conditions { get; set; }
        //public new ConditionLinkOperator LinkOperator
        //{
        //    get
        //    {
        //        if (Conditions != null) 
        //            return Conditions.DefaultLink;
        //        else
        //            return base.LinkOperator;
        //    }
        //    set
        //    {
        //        if (Conditions != null) // base class constructor is first and sets LinkOperator
        //            Conditions.DefaultLink = value;
        //        base.LinkOperator = value;
        //    }
        //}

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            if (this.Conditions.Count() > 0) {
                if (IsNegative) 
                    sql.Append("(NOT ");
                sql.Append('(');

                Conditions.BuildSQL(sql, parameters, indent);

                sql.Append(')');
                if (IsNegative) 
                    sql.Append(')');

                if (this.Parameters.Count() > 0) 
                    parameters.AddParameters(this.Parameters);
            }
        }
    }
}
