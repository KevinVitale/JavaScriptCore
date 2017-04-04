log("Called from JavaScript.");
log("Sum: '" + sum + "'");
log("First: '" + _.first([5, 4, 3, 2, 1]) + "'");

var time = moment("20111031", "YYYYMMDD").fromNow();

var factorial = function(n) {
    if (n < 0)
        return;
    if (n === 0)
        return 1;
    return n * factorial(n - 1);
};
