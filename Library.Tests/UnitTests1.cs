using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Text.RegularExpressions;
using System.Collections.Generic;

namespace Library.Tests
{
    [TestClass]
    public class UnitTests1
    {
        [TestMethod]
        public void TestConvert()
        {
            Double d = 100.5;
            Object o = d;
            Assert.AreEqual(100, Convert.ToInt32(o));

            o = "100.5";
            d = Convert.ToDouble("100.5");
            Assert.AreEqual("101", String.Format("{0:####0}",d));

            Assert.AreEqual("101", String.Format("{0:####0}", Convert.ToDouble("100.5")));
        }

        [TestMethod]
        public void TestRegex()
        {
            String columnInfo = "\t[table].[column] alias\n";
            String cleaned = Regex.Replace(columnInfo, "[^\\040-\\177]", "");
            //String cleaned = Regex.Replace(columnInfo, "[^!-~]", "");
            //String cleaned = Regex.Replace(columnInfo, "[^0-9a-zA-Z]", "");

            
            Assert.AreEqual("[table].[column] alias", cleaned);
        }

        [TestMethod]
        public void TestRemove()
        {
            String s1 = "123456789";
            String s2 = s1.Remove(s1.Length - 1);
            Assert.AreEqual("12345678", s2);
        }

        //[TestMethod]
        //public void TestSplitCSV()
        //{
        //    string[] results = SplitCSV("[schema].[table] alias");
        //}

        //public static string[] SplitCSV(string input)
        //{
        //    Regex csvSplit = new Regex("(?:^|,)(\"(?:[^\"]+|\"\")*\"|[^,]*)", RegexOptions.Compiled);
        //    List<string> list = new List<string>();
        //    string curr = null;
        //    foreach (Match match in csvSplit.Matches(input))
        //    {
        //        curr = match.Value;
        //        if (0 == curr.Length)
        //        {
        //            list.Add("");
        //        }

        //        list.Add(curr.TrimStart(','));
        //    }

        //    return list.ToArray();
        //}



    }
}
