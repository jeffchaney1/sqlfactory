using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Tests
{
    public static class AssertSQL
    {
        private static String formatChar(char c)//, string marker)
        {
            return String.Format("=>{0:c}<=", c, Convert.ToInt32(c));//, marker);
        }

        [System.Diagnostics.DebuggerStepThrough]
        public static void AreEqual(string expected, string actual, string message = "") {
            int epos = 0;
            int apos = 0;

            while ((epos < expected.Length) && (apos < actual.Length))
            {
                // Commands and literals need to be matched up regardless of case.
                Char expC = Char.ToUpper(expected[epos]);
                Char actC = Char.ToUpper(actual[apos]);

                // Ranges of characters that are whitespace match up regardless of 
                // what kind of whitespace, ' ', /t, /n, /r
                //  and the length of those ranges
                if (Char.IsWhiteSpace(expC) && Char.IsWhiteSpace(actC))
                {
                    while (epos < expected.Length && char.IsWhiteSpace(expC))
                    {
                        epos++;
                    }
                    while (apos < actual.Length && char.IsWhiteSpace(actC))
                    {
                        apos++;
                       
                    }
                }
                else if (expC != actC)
                {
                    throw new AssertFailedException("AssertSQL.AreEqual Failed\n" + (String.IsNullOrEmpty(message) ? "" : message + "\n") +
                       "Expected:<" + expected.Remove(epos, 1).Insert(epos, formatChar(expected[epos])) + ">\n\n" +
                       "Actual:<" + actual.Remove(apos,1).Insert(apos, formatChar(actual[apos])) + ">");
                }
                else {
                    epos++;
                    apos++;
                }

            }

            if ((epos < expected.Length) && (apos >= actual.Length))
            {
                while (epos < expected.Length)
                {
                    if (!Char.IsWhiteSpace(expected[epos]))
                        throw new AssertFailedException("AssertSQL.AreEqual Failed\n" + (String.IsNullOrEmpty(message) ? "" : message + "\n") +
                           "Expected:<" + expected.Remove(epos, 1).Insert(epos, formatChar(expected[epos])) + ">\n\n" +
                           "Actual:<" + actual + "=><=" + ">");
                    epos++;
                }
            }
            else if ((epos >= expected.Length) && (apos < actual.Length))
            {
                while (apos < actual.Length)
                {
                    if (!Char.IsWhiteSpace(actual[apos]))
                        throw new AssertFailedException("AssertSQL.AreEqual Failed\n" + (String.IsNullOrEmpty(message) ? "" : message + "\n") +
                           "Expected:<" + expected + "=><=" + ">\n\n" +
                           "Actual:<" + actual.Remove(apos, 1).Insert(apos, formatChar(actual[apos])) + ">");
                    apos++;
                }
            }

        }
    }
}
