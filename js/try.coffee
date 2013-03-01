$('<script src="lib/dist/batman.jquery.js"></script>').appendTo('head')
$('<script src="js/codemirror.js"></script>').appendTo('head')
$('<script src="js/modes/javascript.js"></script>').appendTo('head')
$('<link rel="stylesheet" href="css/codemirror.css" />').appendTo('head')

cm = CodeMirror $('.code-editor-text').html('')[0],
	value: "var foo = 'bar'\nfoo += 'baz'"
	mode: "javascript"
