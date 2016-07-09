using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

public static class StringExtensions
{
    public static String ParseNext(this String s, out String result, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
    {
        if (s == null)
        {
            result = "";
            return null;
        }
        int p = 0;
        result = s.ParseNext(ref p, Delimiters, Quotes, Brackets);
        s = s.Substring(p, s.Length - p);
        return s;
    }

    public static String ParseNext(this String s, ref int p, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
    {
        if (s == null)
            return "";

        String result = "";
        bool inQuotes = false;
        int inBrackets = -1;
        Char matchingQuote = ' ';
        String matchingBracket = "";
        if (p < 0)
            p = 0;
        if (p > s.Length)
            return "";

        int b = p;
        while ((p < s.Length) && (inQuotes || (inBrackets >= 0) || (Delimiters.IndexOf(s[p]) == -1)))
        {
            if (inQuotes && (s[p] == matchingQuote))
                inQuotes = false;
            else if (Quotes.IndexOf(s[p]) >= 0)
            {
                inQuotes = true;
                matchingQuote = s[p];
            }
            else if ((inBrackets >= 0) && (s[p] == matchingBracket[inBrackets]))
            {
                inBrackets -= 1;
                matchingBracket = matchingBracket.Remove(matchingBracket.Length - 1);
            }
            else
            {
                int i = Brackets.IndexOf(s[p]);
                if (i >= 0)
                {
                    inBrackets += 1;
                    matchingBracket += Brackets[i + 1];
                }
            }
            p += 1;
        }

        result = s.Substring(b, p - b);
        if (p < s.Length)
        {
            p += 1;
        }

        return result;
    }

    public static String ParsePrev(this string s, out String result, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
    {
        if (s == null)
        {
            result = "";
            return null;
        }
        int p = s.Length;
        result = s.ParsePrev(ref p, Delimiters, Quotes, Brackets);
        s = s.Substring(0, p + 1);
        return s;
    }

    public static String ParsePrev(this string s, ref int p, String Delimiters = ",", String Quotes = "\"", String Brackets = "[]()")
    {
        if (s == null)
            return "";

        String result = "";
        bool inQuotes = false;
        int inBrackets = -1;
        Char matchingQuote = ' ';
        String matchingBracket = "";
        if (p >= s.Length)
            p = s.Length - 1;
        if (p < 0)
            return "";

        int b = p;
        while ((p >= 0) && (inQuotes || (inBrackets >= 0) || (Delimiters.IndexOf(s[p]) == -1)))
        {
            if (inQuotes && (s[p] == matchingQuote))
                inQuotes = false;
            else if (Quotes.IndexOf(s[p]) >= 0)
            {
                inQuotes = true;
                matchingQuote = s[p];
            }
            else if ((inBrackets >= 0) && (s[p] == matchingBracket[inBrackets]))
            {
                inBrackets -= 1;
                matchingBracket = matchingBracket.Remove(matchingBracket.Length - 1);
            }
            else
            {
                int i = Brackets.IndexOf(s[p]);
                if (i > 0)
                {
                    inBrackets += 1;
                    matchingBracket += Brackets[i - 1];
                }
            }
            p -= 1;
        }
        result = s.Substring(p + 1, b - p);
        if (p > 0)
        {
            p -= 1;
        }
        return result;
    }

    public static String RemoveBrackets(this String value, String beginningBracket, String endingBracket)
    {
        if (value != null) { 
            if (value.StartsWith(beginningBracket))
            {
                value = value.Substring(beginningBracket.Length);
            }
            if (value.EndsWith(endingBracket))
            {
                value = value.Substring(0, value.Length - endingBracket.Length);
            }
        }
        return value;
    }

    public static String EnforceBrackets(this String value, String beginningBracket, String endingBracket)
    {
        if (value != null)
        {
            if (value.StartsWith(beginningBracket))
            {
                value = beginningBracket + value;
            }
            if (value.EndsWith(endingBracket))
            {
                value = value + endingBracket;
            }
        }
        return value;
    }


}
