using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Tests.StringTests
{
    [TestClass]
    public class StringExtensionsTexts
    {
        [TestMethod]
        public void TestParseNext()
        {
            String columnInfo = "[table].[column] alias";
            String tableAlias;
            String columnExpression;
            String columnAlias;
            int p = 0;
            tableAlias = columnInfo.ParseNext(ref p, ".", "\"'", "[]()");

            Assert.AreEqual("[table]", tableAlias);

            columnExpression = columnInfo.ParseNext(ref p, " ", "\"'", "[]()");

            Assert.AreEqual("[column]", columnExpression);

            columnAlias = columnInfo.ParseNext(ref p, " ", "\"'", "[]()");

            Assert.AreEqual("alias", columnAlias);

            columnInfo = "([table].[column1] + [table].[column2]) alias";
            p = 0;

            columnExpression = columnInfo.ParseNext(ref p, " ", "\"", "[]()");
            columnAlias = columnInfo.ParseNext(ref p, " ", "\"'", "()");

            Assert.AreEqual("alias", columnAlias);
            Assert.AreEqual("([table].[column1] + [table].[column2])", columnExpression);


            // Test Consuming version of ParseNext
            columnInfo = columnInfo.ParseNext(out columnExpression, " ", "\"", "[]()");
            Assert.AreEqual("([table].[column1] + [table].[column2])", columnExpression);
            Assert.AreEqual("alias", columnInfo);

            columnInfo = columnInfo.ParseNext(out columnAlias, " ", "\"'", "[]()");
            Assert.AreEqual("alias", columnAlias);
            Assert.AreEqual("", columnInfo);
        }

        //public static String ParseNext(ref String s, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
        //{
        //    if (s == null)
        //        return "";
        //    int p = 0;
        //    String result = ParseNext(ref p, s, Delimiters, Quotes, Brackets);
        //    s = s.Substring(p, s.Length-p);
        //    return result;
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

        [TestMethod]
        public void TestParsePrev()
        {
            String columnInfo = "[table].[column] alias";
            String tableAlias;
            String columnExpression;
            String columnAlias;
            int p = columnInfo.Length;
            columnAlias = columnInfo.ParsePrev(ref p, " ", "\"'", "[]()");

            Assert.AreEqual("alias", columnAlias);

            columnExpression = columnInfo.ParsePrev(ref p, ".", "\"'", "[]()");

            Assert.AreEqual("[column]", columnExpression);

            tableAlias = columnInfo.ParsePrev(ref p, " ", "\"'", "[]()");

            Assert.AreEqual("[table]", tableAlias);

            columnInfo = "([table].[column1] + [table].[column2]) alias";
            p = columnInfo.Length;

            columnAlias = columnInfo.ParsePrev(ref p, " ", "\"'", "()");
            columnExpression = columnInfo.ParsePrev(ref p, ".", "\"", "[]()");
            tableAlias = columnInfo.ParsePrev(ref p, " ", "\"'", "[]()");

            Assert.AreEqual("alias", columnAlias);
            Assert.AreEqual("([table].[column1] + [table].[column2])", columnExpression);
            Assert.AreEqual("", tableAlias);

            // Test Consuming version of ParsePref
            columnInfo = columnInfo.ParsePrev(out columnAlias, " ", "\"'", "()");
            Assert.AreEqual("alias", columnAlias);
            Assert.AreEqual("([table].[column1] + [table].[column2])", columnInfo);

            columnInfo = columnInfo.ParsePrev(out columnExpression, ".", "\"", "[]()");
            Assert.AreEqual("([table].[column1] + [table].[column2])", columnExpression);
            Assert.AreEqual("", columnInfo);

            columnInfo = columnInfo.ParsePrev(out tableAlias, " ", "\"'", "[]()");
            Assert.AreEqual("", tableAlias);
            Assert.AreEqual("", columnInfo);

        }

        [TestMethod]
        public void TestRemoveBrackets()
        {
            String result = "[table]".RemoveBrackets("[", "]");
            Assert.AreEqual("table", result);

            result = "table]".RemoveBrackets("[", "]");
            Assert.AreEqual("table", result);

            result = "[table".RemoveBrackets("[", "]");
            Assert.AreEqual("table", result);

            result = "[[table]]".RemoveBrackets("[", "]");
            Assert.AreEqual("[table]", result);
        }

        //public static String RemoveBrackets(String beginningBracket, String value, String endingBracket) {
        //    if (value.StartsWith(beginningBracket)) {
        //        value = value.Substring(beginningBracket.Length);
        //    }
        //    if (value.EndsWith(endingBracket)) {
        //        value = value.Substring(0, value.Length-endingBracket.Length);
        //    }
        //    return value;
        //}
    }
}
