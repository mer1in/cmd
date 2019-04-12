#!/usr/bin/env node
const os = require('os');
const { spawn } = require('child_process');
const stripAnsi = require('strip-ansi');
const chalk = require('chalk');
const readline = require('readline');
const eol=os.EOL;
const log = console.log;
const assign = Object.assign;
const q = s=>s.join(' ').split(' ');
const fl = (s, i)=>s+' '.repeat(i-s.length);
const vargs = {p: [], x: ['.svn', '.git', 'build', 'node_modules'], i: [], xn: []};
const f_cpp = q`cpp h c hpp inl cu`;
const f_js = q`js ts jsx json coffee`;
const re = /[\u001b\u009b][[()#;?]*(?:[0-9]{1,4}(?:;[0-9]{0,4})*)?[0-9A-ORZcf-nqry=><]/g;
const opts = [
{key: 'help', descr: 'Show help and exit', f: ()=>{help(); process.exit()}},
{key: 'path', descr: 'Search path dirs', f: a=>vargs.p.push(a), a: 1},
{key: 'x', descr: 'Exclude dir', f: a=>vargs.x.push(a), a: 1},
{key: 'cpp', descr: 'Limit search to c++ files: '+f_cpp,
    f: _=>vargs.i = [...vargs.i, ...f_cpp.map(s=>'*.'+s)]},
{key: 'cmake', descr: 'Limit search to cmake files',
    f: _=>vargs.i = [...vargs.i, ...q`cmake txt`.map(s=>'*.'+s)]},
{key: 'js', descr: 'Limit search to javascript files: '+f_js,
    f: _=>vargs.i = [...vargs.i, ...f_js.map(s=>'*.'+s)]},
{key: 'py', descr: 'Limit search to python files', f: _=>vargs.i.push('*.py')},
{key: 'json', descr: 'Limit search to .json files', f: _=>vargs.i.push('*.json')},
{key: 'css', descr: 'Limit search to .css files', f: _=>vargs.i.push('*.css')},
{key: 'name', descr: 'Search only specified files', f: a=>vargs.i.push(a), a: 1},
{key: 'xname', descr: 'Exclude specified files', f: a=>vargs.xn.push(a), a: 1},
{key: 'ni', descr: 'Non interactive mode'},
{key: 'nc', descr: 'No color'},
{key: 'ci', descr: 'Case insencitive'},
{key: 'verbose', descr: 'Show how grep is invoked'},
{key: 'nox', descr: 'No default exclude (just .svn and .git remain)'},
];
const help = ()=>{
    const len = opts.reduce((l, c)=>l>c.key.length ? l : c.key.length, 0);
    log(`grep project folder recursievly and open results in vim${eol}usage:${eol}`+
        opts.reduce((l, c)=>l+'--'+fl(c.key, len)+' : '+c.descr+eol, ''));
};
process.argv = process.argv.slice(2);
let expr = [];
while (process.argv.length)
{
    let word = process.argv.shift();
    let op = opts.find(opt=>'--'+opt.key==word);
    if (!op)
    {
        expr.push(word);
        continue;
    }
    if (op.f)
        op.f(process.argv[0]);
    else
        vargs[op.key] = 1;
    if (op.a)
        process.argv.shift();
}
if (!vargs.p.length)
    vargs.p = ['.'];
let args = [`${!vargs.nc ? '--color=always' : ''}`,
    ...vargs.x.map(s=>'--exclude-dir='+s), ...vargs.i.map(s=>'--include='+s),
    ...vargs.xn.map(s=>'--exclude='+s), `-I${vargs.ci ? 'i' : ''}nr`,
    expr.join('\\|'), ...vargs.p].filter(l=>l);
if (vargs.verbose)
    log('grep '+args.join(' '));
let kid = spawn('grep', args);
let buf_printed = 0;
let buf = '';
let err = '';
const printLine = (i, l)=>{
    if (vargs.nc)
        return log(i+':'+l);
    let ms = l.match(/([^:]+)/g);
    log(chalk.red(i)+':'+chalk`{yellow ${stripAnsi(ms[0])}}:{green ${stripAnsi(ms[1])}}:${ms[2]}`);
};
kid.stdout.on('data', ch=>{
    buf += ch.toString();
    buf.split('\n').filter(l=>l).forEach((l, i, a)=>{
        if (i<buf_printed || i>a.length-2)
            return;
        printLine(i+1, l);
        buf_printed++;
    });
});
kid.stderr.on('data', ch=>err += ch.toString());
kid.on('close', e=>{
    let files = {};
    const add_file = n=>files[buf[0+n-1].replace(re, '')
        .replace(/:.*/g, '')] = buf[0+n-1].replace(/[^:]*:/, '')
        .replace(/:.*/, '');
    buf = buf.split('\n').filter(l=>l).map(l=>l.replace(/\r/g, ''));
    printLine(buf.length, buf[buf.length-1]);
    if (e)
        log('error: '+err) || process.exit();
    if (vargs.ni || !buf.length)
        process.exit();
    buf.forEach((l, i)=>add_file(i+1));
    log(Object.keys(files).length+' files found');
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });
    rl.on('line', line=>{
        if (line)
        {
            files = {};
            line.split(' ').forEach(add_file);
        }
        let args = Object.keys(files), vim = 'vim', qts = '';
        let ops = {stdio: 'inherit'};
        let search_str = `+/${vargs.ci ? '\\c' : ''}${qts}`+
            `${expr.join('\\\|')}${qts}`;
        if (process.platform === "win32")
        {
            vim = 'c:\\windows\\vim.bat';
            qts = '"';
            search_str = `+/${vargs.ci ? '\\c' : ''}${qts}`+
                `${expr.join('\\%PSM%')}${qts}`
            ops = assign(ops, {shell: true, env: assign(process.env, {PSM: '|'})});
        }
        spawn(vim, [...args, `-O${args.length>3 ? 3 : args.length}`,
            search_str, '-c', files[args[0]].replace(re, '')], ops);
        rl.close();
    });
});
