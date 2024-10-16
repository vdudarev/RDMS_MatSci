var startTouchX = 0;
var minWidthRubricsExpand = 576;    // 1200
document.addEventListener('touchstart', onTouchStart, { passive: true });

//$(document).on('touchstart', function (e) {
function onTouchStart(e) {
    e.stopPropagation();
    startTouchX = e.changedTouches[0].pageX;
    //console.log('touchstart startTouchX=' + startTouchX);
}//onTouchStart

//реация на LI каталога, direct - in (фокус) или out (увели фокус)
function onMouseCatLi(e, obj, direct) {
    //если моб. версия, то активация обрабатывается при клике
    //console.log('$(window).width() = ' + $(window).outerWidth());
    if ($(window).outerWidth() < minWidthRubricsExpand || startTouchX !== 0) {
        return false;
    }
    //e.preventDefault(); //НЕ НУЖНО
    //e.stopPropagation(); //НУЖНО

    //console.log('onMouseCatLi ' + direct + ' : ' + $('>a',obj).text() + ' : ' + $(obj).attr('id'));
    if (direct === 'in') { rubricActive($(obj)); }
    else { // out

        $(obj).oneTime(800, "hide_li",
            function () {
                rubricHide($(obj));
            });
    }
}//end onMouseCatLi

//клик на рубрике
function onClickCatLi(e, obj, tree) {
    //console.log('.menu-cat li click ' + $('>a', obj).text() + ' : ' +  obj.hasClass('active') + ' : ' + obj.attr('id') + ' startTouchX = ' + startTouchX);
    //if ($(window).width() >= 992) $(this).mouseover();
    if ($(window).outerWidth() < minWidthRubricsExpand || startTouchX !== 0) { //startTouchX!==0 определяет событие touchstart, которое возникает на планшетах
        e.stopPropagation();
        //если мобильная версия и категория активна, то приклике скроем дочерний блок, т.е. как бы toggle
        if (obj.hasClass('active')) {

            //console.log('.menu-cat li click rubricHide ');

            rubricHide(obj);
        }
        else {
            //console.log('.menu-cat li click rubricActive : ul length = ' + $('ul', obj).length + ' : ' + (tree !== null));
            //ВЕРСИЯ АЯКСА
            if (tree !== null) buildCatalogMain(tree, obj.attr('id'));
            rubricActive(obj);
        }
        //console.log('.menu-cat li click 2 ul length = ' + $('ul', obj).length);
        if ($('ul', obj).length === 0) return true;
    }
    else {
        return tree;
    }
    return false;
}

//реакция на клик в мобильном меню и на + в каталоге
function showMenuMobile(obj) {
    obj.toggleClass('menu-on');
    //если класс выключается, то нужно спрятать и каталог при скрытии основного меню  в разрешении менеее 768
    if (!obj.hasClass('menu-on')) {
        $('ul', obj).removeClass('active-block');
        $('li', obj).removeClass('active');
        if ($('.menu-cat').hasClass('menu-on')) {
            $('.menu-cat').toggleClass('menu-on');
        }
    }
}

//отображение вьранной рубрики (по клику или наведению)
function rubricActive(obj_li) {
    //console.log("0 $(this).attr('id') = " + obj_li.attr('id'));
    $('.menu-cat ul').removeClass('active-block').stopTime('hide_ul');
    //console.log("1 $('.menu-cat ul').removeClass('active-block').stopTime('hide_ul');");
    $('.menu-cat li').removeClass('active').stopTime('hide_li');
    //console.log("2 $('.menu-cat li').removeClass('active').stopTime('hide_li');");
    obj_li.parentsUntil('.menu-cat', 'ul').addClass('active-block');
    //console.log("3 $(this).parentsUntil('.menu-cat', 'ul').addClass('active-block');");
    obj_li.parentsUntil('.menu-cat', 'li').addClass('active');
    //console.log("4 $(this).parentsUntil('.menu-cat', 'li').addClass('active');");
    obj_li.addClass('active');
    //console.log("5 $(this).addClass('active');" + $(this).attr('id'));
    //$(this).stopTime("hide_li");
    var obj = $('>ul', obj_li);
    if (obj.length !== 0) {
        obj.addClass('active-block');
        //console.log("6 obj.length=" + obj.length + " : obj.addClass('active-block');");
    }
}//end rubricActive()

//потеря фокуса активной рубрики для десктопов
//или скрытие блока дочерних рубрик с активной рубрики в моб.версии
function rubricHide(obj_li) {
    obj_li.removeClass('active');
    //console.log("7 $(this).removeClass('active'); = " + $(this).attr('id'));
    $('li', obj_li).removeClass('active');
    $('ul', obj_li).removeClass('active-block');
    //console.log("7-1 $('ul', this).removeClass('active-block');");
}

//Построение дерева рубрикатора
function buildCatalog(tree/*, id*/) {
    var result = '';
    var items = [];
    $.each(tree, function (key, val) {
        //if (id !== 0) {
        var IsChilds = val.childs !== null && val.childs.length > 0;
        items.push('<li id="cat_' + val.id + '"' + (IsChilds ? ' data-childs="1"' : '') + '><a href="' + val.url + '">' + val.name + '</a><span></span>' + (IsChilds ? buildCatalog(val.childs/*, val.id*/) : '') + '</li>');
        //}
        //else if (val.childs.length > 0) {
        //    $(buildCatalog(val.childs, val.id)).appendTo($('#cat_' + val.id));
        //}
    });//end $.each
    if (items.length > 0) {
        //console.log('items.join("") ' + items.join(""));
        return '<ul class="child-cat">' + items.join("") + '</ul>';
    }
    return result;
}//end buildCatalog

//Построение ПОДдерева рубрикатора для конкретной главной рубрики
function buildCatalogMain(tree, id) {
    var objLink = $('#' + id);
    //console.log('buildCatalogMain #' + id + ' : tree ' + tree.length);
    //если для главной рубрики уже построили поддерево - нах выходим
    if ($('.child-cat', objLink).length > 0) return;

    //строим поддерево
    $.each(tree, function (key, val) {

        //console.log('val.id ' + val.id + ' : ' + val.name);

        if (id === 'cat_' + val.id && val.childs.length > 0) {

            $(buildCatalog(val.childs)).appendTo(objLink);

            $('ul', objLink)
                .hover(
                    function (e) {// обработка фокуса на блоке
                        //e.preventDefault(); //НЕ НУЖНО
                        if ($(window).outerWidth() < minWidthRubricsExpand || startTouchX !== 0) return;
                        e.stopPropagation(); //НУЖНО
                        $(this).stopTime('hide_ul');
                        //console.log('mouseOVER ul ' + $(this).parent().attr('id'));
                        $(this).parentsUntil('.menu-cat', 'ul').stopTime('hide_ul');
                        //console.log("UL HOVER IN 9 $(this).parentsUntil('.menu-cat', 'ul').stopTime('hide_ul');");
                    },// block mouseover end
                    function () {// обработка потеря фокуса на блоке
                        if ($(window).outerWidth() < minWidthRubricsExpand || startTouchX !== 0) return;
                        var obj = $(this);
                        //console.log('mousOUT ul ' + $(this).parent().attr('id'));
                        obj.oneTime(1000, 'hide_ul',
                            function () {
                                //obj.trigger('CatHide');
                                //console.log("UL HOVER UOT 10 obj.trigger('CatHide');");
                                $('ul', obj).removeClass('active-block');
                                //console.log("11 $('ul', obj).removeClass('active-block');");
                                $('li', obj).removeClass('active');
                                //console.log("12 $('li', obj).removeClass('active');");
                                //если родительский li не сбросил класс active, значит еще курсор стоит на родительской
                                //рубрике, то прятать сам дочерний блок не нужно
                                if (!obj.parent('li').hasClass('active')) {
                                    obj.removeClass('active-block');
                                    //console.log("13 obj.removeClass('active-block');");
                                }
                            });
                    })// block mouseout end //end $('.menu-cat li ul').hover
                .on('touchmove', { passive: true }, function (e) {
                    //e.preventDefault(); - нельзя это делать, т.к. прокрутка невозможна вниз
                    e.stopPropagation();
                    if (startTouchX !== 0 && $(this).hasClass('active-block') && e.changedTouches[0].pageX - startTouchX < -50) {

                        //console.log('touchmove=' + e.changedTouches[0].pageX + ' : ' + (e.changedTouches[0].pageX - startTouchX) + ' : ' + ($(this).hasClass('active-block') || $(this).hasClass('menu-on')));
                        startTouchX = 0;
                        rubricHide($(this).parent('li'));
                    }
                });

            $('ul li', objLink) // необходимо еще раз назначить обработчки на только что добавленные узлы
                .mouseenter(function (e) { onMouseCatLi(e, this, 'in'); })
                .mouseleave(function (e) { onMouseCatLi(e, this, 'out'); });

            $('li span', objLink).click(function (e) {
                return onClickCatLi(e, $(this).parent(), null);
            });
        }//end if (id === parseInt(val.id))
    });//end $.each
}//end buildCatalog

$(document).ready(function () {
    //скрытие блока меню пальцем влево
    $('ul.menu, ul.menu-cat').on('touchmove', function (e) {
        //e.preventDefault();
        e.stopPropagation();
        if (startTouchX !== 0 && $(this).hasClass('menu-on') && e.changedTouches[0].pageX - startTouchX < -60) {
            startTouchX = 0;
            showMenuMobile($(this));
            //$('ul', $(this)).removeClass('active-block');
            //$('li', $(this)).removeClass('active');
        }
    });

    // обработка наведения на меню
    // $('.menu-cat > li')
    $('.menu-cat li')
        .mouseenter(function (e) {
            if ($(window).outerWidth() < minWidthRubricsExpand || startTouchX !== 0) return;
            e.stopPropagation();
            //console.log('mouseover ' + $('>a', this).text() + ' : ' + $(this).attr('id'));
            //ВАРИАНТ АЯКСА с выводом в код только 0 уровня 
            //buildCatalogMain(data.catalog, $(this).attr('id'));

            onMouseCatLi(e, this, 'in');
        })
        .mouseleave(function (e) {
            //console.log('.menu-cat > li mouseout ' + $('>a', this).text() + ' : ' + $(this).attr('id'));
            onMouseCatLi(e, this, 'out');
        });




});
