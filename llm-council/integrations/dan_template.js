// ============================================================================
// DAN HSSE Management System — shared document template engine
// One source of brand styling, front matter, header/footer and content helpers
// so every document has identical format and shape.
// ============================================================================
const fs = require("fs");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, Header, Footer,
  AlignmentType, LevelFormat, TableOfContents, HeadingLevel, BorderStyle, WidthType,
  ShadingType, VerticalAlign, PageNumber, PageBreak, ImageRun, TabStopType,
} = require("docx");

// ---- DAN brand palette (Brand Book p.22) ----
const BROWN="542A12", OCHRE="B5692B", RED="B33533", BLUE="19648B", GREEN="119D88",
      ORANGE="E68233", GREY="595959", LIGHTBROWN="EFE7E1", FONT="Tahoma";
const ISSUE_DATE = "June 2026";        // <-- global issue date for the whole system

const LOGO = __dirname + "/dan-logo.png";
const hasLogo = fs.existsSync(LOGO);
const noB = () => { const n={style:BorderStyle.NONE,size:0,color:"FFFFFF"};
  return {top:n,bottom:n,left:n,right:n,insideHorizontal:n,insideVertical:n}; };
const thin = {style:BorderStyle.SINGLE,size:4,color:"BFB3AA"};
const cb = {top:thin,bottom:thin,left:thin,right:thin};

// ---------- content helpers (exported to each document) ----------
const H1=(t)=>new Paragraph({heading:HeadingLevel.HEADING_1,children:[new TextRun(t)]});
const H2=(t)=>new Paragraph({heading:HeadingLevel.HEADING_2,children:[new TextRun(t)]});
const H3=(t)=>new Paragraph({spacing:{before:160,after:80},keepNext:true,
  children:[new TextRun({text:t,bold:true,font:FONT,size:20,color:OCHRE})]});
const P=(t,o={})=>new Paragraph({spacing:{after:120,line:276},alignment:AlignmentType.JUSTIFIED,
  children:[new TextRun({text:t,font:FONT,size:20,...o})]});
const bullet=(t)=>new Paragraph({numbering:{reference:"dash",level:0},spacing:{after:60,line:268},
  alignment:AlignmentType.JUSTIFIED,children:[new TextRun({text:t,font:FONT,size:20})]});
const sub=(t)=>new Paragraph({numbering:{reference:"subdash",level:0},spacing:{after:40,line:264},
  children:[new TextRun({text:t,font:FONT,size:18})]});
const num=(t,n)=>new Paragraph({spacing:{after:60,line:268},indent:{left:540,hanging:270},
  children:[new TextRun({text:`${n}.  `,bold:true,font:FONT,size:20,color:BROWN}),
            new TextRun({text:t,font:FONT,size:20})]});
const note=(t)=>new Paragraph({spacing:{before:80,after:120},
  children:[new TextRun({text:"Note:  ",bold:true,font:FONT,size:18,color:BROWN}),
            new TextRun({text:t,font:FONT,size:18,color:"444444"})]});
const quote=(t)=>new Paragraph({spacing:{before:120,after:120},indent:{left:480},
  border:{left:{style:BorderStyle.SINGLE,size:18,color:ORANGE,space:12}},
  children:[new TextRun({text:t,italics:true,font:FONT,size:20,color:"444444"})]});
const spacer=()=>new Paragraph({spacing:{after:60},children:[new TextRun({text:"",size:2})]});

function cell(text,{w,fill,bold,color,head,align,size=18}={}) {
  return new TableCell({ width:w?{size:w,type:WidthType.DXA}:undefined, borders:cb,
    shading: fill?{fill,type:ShadingType.CLEAR,color:"auto"}:undefined,
    margins:{top:60,bottom:60,left:120,right:120}, verticalAlign:VerticalAlign.CENTER,
    children:[new Paragraph({alignment:align,children:[new TextRun({text:String(text),bold:bold||head,
      font:FONT,size,color: color||(head?"FFFFFF":"222222")})]})] });
}
// generic table: headers[], widths[], rows[][]
function table(headers,widths,rows){
  const trs=[ new TableRow({tableHeader:true,children:headers.map((h,i)=>cell(h,{w:widths[i],fill:BROWN,head:true}))}) ];
  rows.forEach(r=>trs.push(new TableRow({children:r.map((c,i)=>
    (c&&typeof c==="object")?cell(c.t,{w:widths[i],fill:c.fill,bold:c.bold,color:c.color,align:c.align})
                            :cell(c,{w:widths[i]}))})));
  return new Table({width:{size:9360,type:WidthType.DXA},columnWidths:widths,rows:trs});
}
// 2-col definition table
function defs(rows){
  return table(["Term","Definition"],[1900,7460],
    rows.map(([t,d])=>[{t,bold:true,color:BROWN},d]));
}
// colour swatch table: rows = [fill,label,desc,darkText]
function colours(title,rows){
  const trs=[ new TableRow({tableHeader:true,children:[ new TableCell({columnSpan:2,borders:cb,
    shading:{fill:BROWN,type:ShadingType.CLEAR,color:"auto"},margins:{top:60,bottom:60,left:120,right:120},
    children:[new Paragraph({children:[new TextRun({text:title,bold:true,font:FONT,size:18,color:"FFFFFF"})]})]}) ]}) ];
  rows.forEach(([fill,label,desc,dark])=>trs.push(new TableRow({children:[
    cell(label,{w:2600,fill:fill||undefined,bold:true,color:dark?"FFFFFF":"222222"}),
    cell(desc,{w:6760}) ]})));
  return new Table({width:{size:9360,type:WidthType.DXA},columnWidths:[2600,6760],rows:trs});
}

// ---------- front matter + assembly ----------
function band(){
  const seg=(fill)=>new TableCell({width:{size:2340,type:WidthType.DXA},
    shading:{fill,type:ShadingType.CLEAR,color:"auto"},borders:noB(),
    children:[new Paragraph({spacing:{before:0,after:0},children:[new TextRun({text:" ",size:8})]})]});
  return new Table({width:{size:9360,type:WidthType.DXA},columnWidths:[2340,2340,2340,2340],
    borders:noB(),rows:[new TableRow({children:[seg(BLUE),seg(GREEN),seg(ORANGE),seg(RED)]})]});
}
function ctrlRow(l,v,l2,v2){
  return new TableRow({children:[cell(l,{w:2340,fill:LIGHTBROWN,bold:true,color:BROWN}),cell(v,{w:2340}),
    cell(l2,{w:2340,fill:LIGHTBROWN,bold:true,color:BROWN}),cell(v2,{w:2340})]});
}

function makeDoc({docno,rev="00",title,short,manualLine,body}){
  const date = ISSUE_DATE;
  // cover
  const cover=[];
  if(hasLogo) cover.push(new Paragraph({spacing:{after:240},children:[new ImageRun({type:"png",
    data:fs.readFileSync(LOGO),transformation:{width:150,height:116},
    altText:{title:"DAN",description:"DAN Company logo",name:"DAN"}})]}));
  else { cover.push(new Paragraph({spacing:{after:60},children:[new TextRun({text:"DAN",font:FONT,size:64,bold:true,color:BROWN})]}));
    cover.push(new Paragraph({spacing:{after:240},children:[new TextRun({text:"C O M P A N Y",font:FONT,size:18,color:BROWN})]})); }
  cover.push(band());
  cover.push(new Paragraph({spacing:{before:480,after:0},children:[new TextRun({text:"HEALTH, SAFETY & ENVIRONMENT MANAGEMENT SYSTEM",font:FONT,size:20,bold:true,color:GREY,characterSpacing:30})]}));
  cover.push(new Paragraph({spacing:{before:40,after:0},children:[new TextRun({text:manualLine||"DAN Construction Safety Manual (DCSM)",font:FONT,size:18,color:GREY})]}));
  cover.push(new Paragraph({spacing:{before:720,after:0},children:[new TextRun({text:title,font:FONT,size:44,bold:true,color:BROWN})]}));
  cover.push(new Paragraph({spacing:{before:200,after:0},border:{top:{style:BorderStyle.SINGLE,size:12,color:ORANGE,space:8}},children:[new TextRun({text:"",font:FONT,size:8})]}));
  cover.push(new Paragraph({spacing:{before:480,after:120},children:[new TextRun({text:"Document Control",font:FONT,size:22,bold:true,color:BROWN})]}));
  cover.push(new Table({width:{size:9360,type:WidthType.DXA},columnWidths:[2340,2340,2340,2340],rows:[
    ctrlRow("Document No.",docno,"Revision",`R${rev}`),
    ctrlRow("Issue Date",date,"Classification","Controlled — Internal"),
    ctrlRow("Document Owner","HSE Department","Page Format","US Letter"),
  ]}));
  cover.push(new Paragraph({spacing:{before:360,after:80},children:[new TextRun({text:"Approval",font:FONT,size:22,bold:true,color:BROWN})]}));
  cover.push(new Table({width:{size:9360,type:WidthType.DXA},columnWidths:[3120,3120,3120],rows:[
    new TableRow({children:["Prepared By","Reviewed By","Approved By"].map(t=>cell(t,{w:3120,fill:LIGHTBROWN,bold:true,color:BROWN}))}),
    new TableRow({children:["HSE Representative","Competent Person (HSE)","Project Director / Manager"].map(t=>new TableCell({
      width:{size:3120,type:WidthType.DXA},borders:cb,margins:{top:200,bottom:200,left:120,right:120},
      children:[new Paragraph({spacing:{after:240},children:[new TextRun({text:t,font:FONT,size:16,color:GREY})]}),
               new Paragraph({children:[new TextRun({text:"Signature / Date",font:FONT,size:14,color:"A0A0A0"})]})]}))}),
  ]}));
  cover.push(new Paragraph({children:[new PageBreak()]}));
  // toc
  const toc=[ new Paragraph({spacing:{after:160},children:[new TextRun({text:"Table of Contents",font:FONT,size:28,bold:true,color:BROWN})]}),
    new TableOfContents("Table of Contents",{hyperlink:true,headingStyleRange:"1-2"}),
    new Paragraph({children:[new PageBreak()]}) ];
  // header/footer
  const header=new Header({children:[
    new Table({width:{size:9360,type:WidthType.DXA},columnWidths:[4680,4680],borders:noB(),rows:[new TableRow({children:[
      new TableCell({width:{size:4680,type:WidthType.DXA},borders:noB(),children:[new Paragraph({children:[
        new TextRun({text:"DAN",bold:true,font:FONT,size:22,color:BROWN}),
        new TextRun({text:"  |  HSSE Management System",font:FONT,size:14,color:GREY})]})]}),
      new TableCell({width:{size:4680,type:WidthType.DXA},borders:noB(),children:[new Paragraph({alignment:AlignmentType.RIGHT,children:[
        new TextRun({text:`${docno} · R${rev}`,font:FONT,size:14,color:GREY})]})]}),
    ]})]}),
    new Paragraph({spacing:{before:40},border:{bottom:{style:BorderStyle.SINGLE,size:6,color:BROWN,space:1}},children:[new TextRun({text:"",size:2})]}),
  ]});
  const footer=new Footer({children:[
    new Paragraph({border:{top:{style:BorderStyle.SINGLE,size:6,color:"BFB3AA",space:4}},
      tabStops:[{type:TabStopType.RIGHT,position:9360}],children:[
        new TextRun({text:short,font:FONT,size:14,color:GREY}),
        new TextRun({text:"\t",font:FONT,size:14}),
        new TextRun({text:"Page ",font:FONT,size:14,color:GREY}),
        new TextRun({children:[PageNumber.CURRENT],font:FONT,size:14,color:GREY}),
        new TextRun({text:" of ",font:FONT,size:14,color:GREY}),
        new TextRun({children:[PageNumber.TOTAL_PAGES],font:FONT,size:14,color:GREY}),
      ]}),
  ]});
  // revision history (standard last section)
  const revHist=[ H1("Revision History"),
    table(["Rev.","Date","Description of Change","Approved By"],[1200,1600,4160,2400],
      [["R00",date,"Initial issue. Restructured to the DAN integrated HSSE management-system template and re-branded in accordance with the DAN Brand Book.","Project Director"]]) ];

  return new Document({
    creator:"DAN HSSE Management System", title,
    styles:{ default:{document:{run:{font:FONT,size:20,color:"222222"}}}, paragraphStyles:[
      {id:"Heading1",name:"Heading 1",basedOn:"Normal",next:"Normal",quickFormat:true,
        run:{size:26,bold:true,font:FONT,color:BROWN},
        paragraph:{spacing:{before:280,after:140},outlineLevel:0,border:{bottom:{style:BorderStyle.SINGLE,size:4,color:"D9CCC2",space:4}}}},
      {id:"Heading2",name:"Heading 2",basedOn:"Normal",next:"Normal",quickFormat:true,
        run:{size:22,bold:true,font:FONT,color:OCHRE},paragraph:{spacing:{before:200,after:100},outlineLevel:1}},
    ]},
    numbering:{config:[
      {reference:"dash",levels:[{level:0,format:LevelFormat.BULLET,text:"–",alignment:AlignmentType.LEFT,
        style:{run:{color:BROWN},paragraph:{indent:{left:540,hanging:270}}}}]},
      {reference:"subdash",levels:[{level:0,format:LevelFormat.BULLET,text:"•",alignment:AlignmentType.LEFT,
        style:{run:{color:ORANGE},paragraph:{indent:{left:900,hanging:270}}}}]},
    ]},
    sections:[
      {properties:{page:{size:{width:12240,height:15840},margin:{top:1440,right:1440,bottom:1440,left:1440}}},children:cover},
      {properties:{page:{size:{width:12240,height:15840},margin:{top:1620,right:1440,bottom:1440,left:1440}}},
        headers:{default:header},footers:{default:footer},children:[...toc,...body,...revHist]},
    ],
  });
}

function write(doc,path){ return Packer.toBuffer(doc).then(b=>{fs.writeFileSync(path,b);console.log("WROTE",path,b.length);}); }

module.exports={ makeDoc, write, H1,H2,H3,P,bullet,sub,num,note,quote,spacer,table,defs,colours,
  BROWN,OCHRE,RED,BLUE,GREEN,ORANGE,GREY, ISSUE_DATE, Paragraph,TextRun };
