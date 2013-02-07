/*import "danish-stemmer.jsx";
import "dutch-stemmer.jsx";
import "english-stemmer.jsx";
import "finnish-stemmer.jsx";
import "french-stemmer.jsx";
import "german-stemmer.jsx";
import "hungarian-stemmer.jsx";
import "italian-stemmer.jsx";
import "norwegian-stemmer.jsx";
import "porter-stemmer.jsx";
import "portuguese-stemmer.jsx";
import "romanian-stemmer.jsx";
import "russian-stemmer.jsx";
import "spanish-stemmer.jsx";
import "swedish-stemmer.jsx";
import "turkish-stemmer.jsx";*/

import "english-stemmer.jsx";

class _Main
{

    static function usage() : void
    {
    }

    static function main (args : string[]) : void
    {
	/*if (args.length < 2) {
            usage();
            return;
        }*/

        var stemmers = {
            English: EnglishStemmer
        };

        var stemmer = new EnglishStemmer;
        var words = args[0].split(/\s\.-/);
        var repeat = 4;
        for (var i = 0; i < words.length; i++)
        {
            if (words[i] == '')
            {
                continue;
            }
            stemmer.setCurrent(words[i].toLowerCase());
            for (var j = 0; j < repeat; j++)
            {
                stemmer.stem();
            }
            log stemmer.getCurrent();
        }
        /*SnowballStemmer stemmer = (SnowballStemmer) stemClass.newInstance();

	Reader reader;
	reader = new InputStreamReader(new FileInputStream(args[1]));
	reader = new BufferedReader(reader);

	StringBuffer input = new StringBuffer();

        OutputStream outstream;

	if (args.length > 2) {
            if (args.length >= 4 && args[2].equals("-o")) {
                outstream = new FileOutputStream(args[3]);
            } else {
                usage();
                return;
            }
	} else {
	    outstream = System.out;
	}
	Writer output = new OutputStreamWriter(outstream);
	output = new BufferedWriter(output);

	int repeat = 1;
	if (args.length > 4) {
	    repeat = Integer.parseInt(args[4]);
	}

	Object [] emptyArgs = new Object[0];
	int character;
	while ((character = reader.read()) != -1) {
	    char ch = (char) character;
	    if (Character.isWhitespace((char) ch)) {
		if (input.length() > 0) {
		    stemmer.setCurrent(input.toString());
		    for (int i = repeat; i != 0; i--) {
			stemmer.stem();
		    }
		    output.write(stemmer.getCurrent());
		    output.write('\n');
		    input.delete(0, input.length());
		}
	    } else {
		input.append(Character.toLowerCase(ch));
	    }
	}
	output.flush();*/
    }
}
