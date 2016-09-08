using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class SQLDeleteFactory : SQLConditionalModifyFactory
    {
        public Table FromTable { get { return GetTable(); } }
        public Boolean AllowNoConditions { get { return GetAllowNoConditions(); } set { SetAllowNoConditions(value); } }
        public ConditionList Where { get { return GetWhere(); } }

        public override void BuildSQL(StringBuilder sql, ParameterList parameters, string indent = "")
        {
            sql.Append("DELETE ");
            base.BuildSQL(sql, parameters, indent);
        }

    }
}
