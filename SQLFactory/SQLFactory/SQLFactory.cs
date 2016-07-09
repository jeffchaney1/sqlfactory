using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Library.SQLFactory
{
    public class ESQLFactoryException : Exception
    {
        public ESQLFactoryException(String message) : base(message) { }
    }
    public class ESQLUpdateNoConditions : Exception
    {
        public ESQLUpdateNoConditions(String message) : base(message) { }
    }
    public class ESQLUpdateNoColumns : Exception
    {
        public ESQLUpdateNoColumns(String message) : base(message) { }
    }
    public enum DataType { dtString, dtInteger, dtBoolean, dtDateTime, dtDouble };
    public enum ConditionLinkOperator { loAND, loOR };
    public enum JoinType {jtJoin, jtLeftJoin, jtRightJoin, jtFullJoin};

    public interface ISQLElement
    {
        void BuildSQL(StringBuilder sql, ParameterList parameters, String indent = "");
        String BuildSQL(ParameterList parameters = null);
        String AsString();
    }

    public static class SQLFactory
    {
        public const String STD_INDENT = "    ";
        public const Char ParameterPlaceholder = ':';
        public const String UNDEFINED = "*UNDEFINED*";

        #region static
        internal static String _BuildSQL(ISQLElement sqlElement, StringBuilder sql = null, ParameterList parameters = null, String indent = "")
        {
            bool localParms = false;

            if (sql == null)
            {
                sql = new StringBuilder();
            }

            if (parameters == null)
            {
                parameters = new ParameterList();
                localParms = true;
            }

            sqlElement.BuildSQL(sql, parameters, indent);
            if (localParms && (parameters.Count() > 0))
            {
                throw new ESQLFactoryException("This SQL contains parameters, " +
                    "but, no parameter list was given to collect them.");
            }
            return sql.ToString();
        }

        internal static String _AsString(ISQLElement sqlElement, bool addParameters = true)
        {
            ParameterList parameters = new ParameterList();
            StringBuilder sql = new StringBuilder();

            SQLFactory._BuildSQL(sqlElement, sql, parameters, "");

            if (addParameters && (parameters != null))
            {
                sql.Append("-- parameters (");
                parameters.AppendString(sql);
                sql.Append(')');
            }


            return sql.ToString();
        }

        //public static String ParseNext(this SQLElementItem me, ref String s, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
        //{
        //    return ParseNext(ref s, Delimiters, Quotes, Brackets);
        //}

        //public static String ParseNext(ref String s, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
        //{
        //    if (s == null)
        //        return "";
        //    int p = 0;
        //    String result = ParseNext(ref p, s, Delimiters, Quotes, Brackets);
        //    s = s.Substring(p, s.Length - p);
        //    return result;
        //}

        //public static String ParseNext(this SQLElementItem me, ref int p, String s, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
        //{
        //    return ParseNext(ref p, s, Delimiters, Quotes, Brackets);
        //}

        //public static String ParseNext(ref int p, String s, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
        //{
        //    if (s == null)
        //        return "";

        //    String result = "";
        //    bool inQuotes = false;
        //    int inBrackets = -1;
        //    Char matchingQuote = ' ';
        //    String matchingBracket = "";
        //    if (p < 0)
        //        p = 0;
        //    if (p > s.Length)
        //        return "";

        //    int b = p;
        //    while ((p < s.Length) && (inQuotes || (inBrackets >= 0) || (Delimiters.IndexOf(s[p]) == -1)))
        //    {
        //        if (inQuotes && (s[p] == matchingQuote))
        //            inQuotes = false;
        //        else if (Quotes.IndexOf(s[p]) >= 0)
        //        {
        //            inQuotes = true;
        //            matchingQuote = s[p];
        //        }
        //        else if ((inBrackets >= 0) && (s[p] == matchingBracket[inBrackets]))
        //        {
        //            inBrackets -= 1;
        //            matchingBracket = matchingBracket.Remove(matchingBracket.Length - 1);
        //        }
        //        else
        //        {
        //            int i = Brackets.IndexOf(s[p]);
        //            if (i >= 0)
        //            {
        //                inBrackets += 1;
        //                matchingBracket += Brackets[i + 1];
        //            }
        //        }
        //        p += 1;
        //    }

        //    result = s.Substring(b, p - b);
        //    if (p < s.Length)
        //    {
        //        p += 1;
        //    }

        //    return result;
        //}

        //public static String ParsePrev(this SQLElementItem me, ref string s, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
        //{
        //    return ParsePrev(ref s, Delimiters, Quotes, Brackets);
        //}

        //public static String ParsePrev(ref string s, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
        //{
        //    if (s == null)
        //        return "";
        //    int p = s.Length;
        //    String result = SQLFactory.ParsePrev(s, ref p, Delimiters, Quotes, Brackets);
        //    s = s.Substring(0, p + 1);
        //    return result;
        //}

        //public static String ParsePrev(this SQLElementItem me, string s, ref int p, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
        //{
        //    return ParsePrev(s, ref p, Delimiters, Quotes, Brackets);
        //}

        //public static String ParsePrev(string s, ref int p, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
        //{
        //    if (s == null)
        //        return "";

        //    String result = "";
        //    bool inQuotes = false;
        //    int inBrackets = -1;
        //    Char matchingQuote = ' ';
        //    String matchingBracket = "";
        //    if (p >= s.Length)
        //        p = s.Length - 1;
        //    if (p < 0)
        //        return "";

        //    int b = p;
        //    while ((p >= 0) && (inQuotes || (inBrackets >= 0) || (Delimiters.IndexOf(s[p]) == -1)))
        //    {
        //        if (inQuotes && (s[p] == matchingQuote))
        //            inQuotes = false;
        //        else if (Quotes.IndexOf(s[p]) >= 0)
        //        {
        //            inQuotes = true;
        //            matchingQuote = s[p];
        //        }
        //        else if ((inBrackets >= 0) && (s[p] == matchingBracket[inBrackets]))
        //        {
        //            inBrackets -= 1;
        //            matchingBracket = matchingBracket.Remove(matchingBracket.Length - 1);
        //        }
        //        else
        //        {
        //            int i = Brackets.IndexOf(s[p]);
        //            if (i > 0)
        //            {
        //                inBrackets += 1;
        //                matchingBracket += Brackets[i - 1];
        //            }
        //        }
        //        p -= 1;
        //    }
        //    result = s.Substring(p + 1, b - p);
        //    if (p > 0)
        //    {
        //        p -= 1;
        //    }
        //    return result;
        //}


        //public static String RemoveBrackets(this SQLElementItem me, String value, String beginningBracket, String endingBracket)
        //{
        //    return RemoveBrackets(beginningBracket, value, endingBracket);
        //}

        //public static String RemoveBrackets(String beginningBracket, String value, String endingBracket)
        //{
        //    if (value.StartsWith(beginningBracket))
        //    {
        //        value = value.Substring(beginningBracket.Length);
        //    }
        //    if (value.EndsWith(endingBracket))
        //    {
        //        value = value.Substring(0, value.Length - endingBracket.Length);
        //    }
        //    return value;
        //}


        //public static void ParseColumnInfo(this SQLElementItem me, String columnInfo, out String tableAlias, out String columnExpression, out String columnAlias)
        //{
        //    ParseColumnInfo(columnInfo, out tableAlias, out columnExpression, out columnAlias);
        //}

        public static String PrintableCharacters = "[\\040-\\177]";
        public static String NonPrintableCharacters = PrintableCharacters.Insert(1, "^");
        public static String IdentifierBodyCharacters = "[0-9A-Za-z_]";
        public static String NotIdentifierBodyCharacters = IdentifierBodyCharacters.Insert(1, "^");

        public static void ParseColumnInfo(String columnInfo, out String tableAlias, out String columnExpression, out String columnAlias)
        {
            tableAlias = "";
            columnExpression = "";
            columnAlias = "";

            String cleaned = Regex.Replace(columnInfo, "[^\\040-\\177]", "");
            int p = columnInfo.Length;
            columnAlias = cleaned.ParsePrev(ref p, " ", "\"", "[]");
            if (p > 0)
            {
                columnAlias = columnAlias.RemoveBrackets("[", "]");

                if (columnAlias == columnAlias.Replace(NotIdentifierBodyCharacters, ""))
                {
                    cleaned = cleaned.Substring(0, p + 1);
                    String tmp = cleaned.ParsePrev(ref p, " ", "\"", "");
                    if (tmp.Equals("AS", StringComparison.OrdinalIgnoreCase))
                        cleaned = cleaned.Substring(1, p);
                }
                else
                {
                    columnAlias = "";
                }
            }
            else /*there was no alias delimited by a space*/
            {
                columnAlias = "";
            }

            p = 0;
            columnExpression = cleaned.ParseNext(ref p, ".", "\"'", "[]()");
            tableAlias = "";
            while (p < cleaned.Length)
            {
                if (String.IsNullOrEmpty(tableAlias))
                    tableAlias = columnExpression;
                else
                    tableAlias = tableAlias + "." + columnExpression;
                columnExpression = cleaned.ParseNext(ref p, ".", "\"'", "[]()");
            }
        }

        public static bool IsIdentifier(this SQLElementItem me, String value)
        {
            return IsIdentifier(value);
        }

        public static bool IsIdentifier(String value)
        {
            if (!String.IsNullOrEmpty(value))
            {
                value = Regex.Replace(value, IdentifierBodyCharacters, "");
                return value.Length == 0;
            }
            else
                return false;
        }
        // Can IsIdentifier and IsIdentOnly be combined?
        public static bool IsIdentOnly(String expression)
        {
            return (Regex.Replace(expression, @"[0-9A-Za-z_\x2E\x5B\x5D]", "").Count() == 0);
        }

        public static String MyIdent(this SQLElementItem me, String identPrefix, bool addDelimiters)
        {
            return (addDelimiters ? "[" : "") + 
                    identPrefix +
                    me.GetHashCode() +
                   (addDelimiters ? "]" : "");
        }

        public static bool IsNumericType(Object value) {
            return IsIntegerType(value) || IsFloatType(value);
        }

        public static bool IsIntegerType(Object value) {
            if (value == null) 
                return false;
            return value is sbyte
                    || value is byte
                    || value is short
                    || value is ushort
                    || value is int
                    || value is uint
                    || value is long
                    || value is ulong;
        }

        public static bool IsFloatType(Object value) {
            if (value == null) 
                return false;
            return  value is float
                    || value is double
                    || value is decimal;
        }

        public static bool IsAnsiOnly(String value)
        {
            // http://stackoverflow.com/questions/1522884/c-sharp-ensure-string-contains-only-ascii
            // http://snipplr.com/view/35806/
            // ASCII encoding replaces non-ascii with question marks, so we use UTF8 to see if multi-byte sequences are there
            return Encoding.UTF8.GetByteCount(value) == value.Length;
        }

        public static TimeZone DatabaseTimeZone = TimeZone.CurrentTimeZone;

        public static String ValueToSQLLiteralValue(Object value)
        {
            if (value == null)
            {
                return "NULL";
            }
            else if (IsFloatType(value)) {
                // We want to ensure that the decimal placehold user is always a period
                CultureInfo enUS = CultureInfo.GetCultureInfo("en-US");
                return String.Format(enUS, "{0:##############0.0#########}", Convert.ToDouble(value));
            }
            else if (IsIntegerType(value))
            {
                return String.Format("{0:################0}", Convert.ToInt64(value));
            }
            else if ((value is DateTime) || (value is DateTimeOffset))
            {
                DateTime dt;
                if (value is DateTimeOffset)
                {
                    dt = ((DateTimeOffset)value).LocalDateTime;
                    //dt = dt.Add(((DateTimeOffset)value).Offset);

                    //((DateTimeOffset)value).
                }
                else
                    dt = (DateTime)value;

                if (dt.TimeOfDay.TotalMilliseconds == 0)
                    return "'" + String.Format("{0:yyyy-MM-dd}", dt) + "'";
                else
                    return "'" + String.Format("{0:yyyy-MM-dd HH:mm:ss.FFF}", dt) + "'";
            }
            else if (value is Boolean)
            {
                if ((Boolean)value)
                    return "1/*True*/";
                else
                    return "0/*False*/";
            }
            else
            {
                String tmp = Regex.Replace(value.ToString(), "'", "''");
                if (IsAnsiOnly(tmp))
                    return "'" + tmp + "'";
                else
                    return "N'" + tmp + "'";
            }
        }

        public static String LinkOperatorToSQL(ConditionLinkOperator linkOp) {
            switch(linkOp) {
                case ConditionLinkOperator.loOR: 
                    return "OR";
                default: //ConditionLinkOperator.loAND: 
                return "AND";
            }
        }


        #endregion


    }

}
