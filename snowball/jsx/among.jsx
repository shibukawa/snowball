//import java.lang.reflect.Method;

class Among
{
    var s_size : int;                   /* search string */
    var s : string;                     /* search string */
    var substring_i : int;              /* index to longest matching substring */
    var result : int;                   /* result of the lookup */
    var method : function() : string;   /* method to use if substring matches */
    var methodobject : variant;         /* object to invoke method on. It is a SnowballStemmer */

    function constructor (s : string, substring_i : int, result : int,
                          methodname : string, methodobject : variant)
    {
        this.s_size = s.length;
        this.s = s;
        this.substring_i = substring_i;
	this.result = result;
	this.methodobject = methodobject;
	if (methodname.length == 0)
        {
	    this.method = null;
	}
        else
        {
	    /*try
            {
		this.method = methodobject.getClass().
		getDeclaredMethod(methodname, new Class[0]);
	    }
            catch (NoSuchMethodException e)
            {
		throw new RuntimeException(e);
	    }*/
	}
    }
}
