import 'package:maxi_library/maxi_library.dart';


mixin IFunctionalTaskSerie<T> on IFunctionalTask<T> {
  void setSeriesOperator({required SeriesFunctions seriesOperator, required dynamic previousResult});
}
