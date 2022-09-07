'use strict';

var Caml_obj = require("../../lib/js/caml_obj.js");

var vicky = {};

var teacher = {};

Caml_obj.update_dummy(vicky, {
      taughtBy: teacher
    });

Caml_obj.update_dummy(teacher, {
      students: [vicky]
    });

exports.vicky = vicky;
exports.teacher = teacher;
/* No side effect */