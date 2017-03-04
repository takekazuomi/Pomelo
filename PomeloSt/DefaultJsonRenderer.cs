using System.Globalization;

namespace PomeloSt
{
    class DefaultJsonRenderer : JsonRenderer
    {
        public override string ToString(object o, string formatString, CultureInfo culture)
        {
            if (formatString == null)
                return JsonToString(o);
            return base.ToString(o, formatString, culture);
        }
    }
}
