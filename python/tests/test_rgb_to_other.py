import unittest
import numpy as np

from pyrism.colorspace import rgb_to_xyz, rgb_to_ycbcr, rgb_to_rgb


class TestRgbToXyz(unittest.TestCase):
    def setUp(self) -> None:
        self.rgb_data = np.array([[0.814723686393179, 0.157613081677548, 0.655740699156587],
                                  [0.905791937075619, 0.970592781760616, 0.0357116785741896],
                                  [0.126986816293506, 0.957166948242946, 0.849129305868777],
                                  [0.913375856139019, 0.485375648722841, 0.933993247757551],
                                  [0.632359246225410, 0.800280468888800, 0.678735154857774],
                                  [0.0975404049994095, 0.141886338627215, 0.757740130578333],
                                  [0.278498218867048, 0.421761282626275, 0.743132468124916],
                                  [0.546881519204984, 0.915735525189067, 0.392227019534168],
                                  [0.957506835434298, 0.792207329559554, 0.655477890177557],
                                  [0.964888535199277, 0.959492426392903, 0.171186687811562]])

        return super().setUp()

    def test_srgb(self) -> None:
        xyz_srgb_data = np.array([[0.337022048279929, 0.177048856732710, 0.383067475200876],
                                  [0.664094760025734, 0.838336983955635, 0.129447051363532],
                                  [0.454419176988889, 0.700431980369530, 0.764511364979417],
                                  [0.562087803455028, 0.378513856283563, 0.853667738249533],
                                  [0.439068186708654, 0.538422846925930, 0.476551208430729],
                                  [0.106837031372421, 0.0533761864600793, 0.510519687368064],
                                  [0.171531993916981, 0.156657099015557, 0.505499937939584],
                                  [0.423071453387219, 0.650154602077139, 0.223815617421220],
                                  [0.654749347076620, 0.643064334065245, 0.455952511114873],
                                  [0.710210025506997, 0.848868871020854, 0.149925631511349]])

        xyz = rgb_to_xyz(self.rgb_data, 'sRGB')
        np.testing.assert_almost_equal(xyz, xyz_srgb_data, decimal=10)

    def test_p3d65(self) -> None:
        xyz_p3d65_data = np.array([[0.388594010686544, 0.189573249581654, 0.405521092712978],
                                   [0.637520815660353, 0.829514238240341, 0.0450395834099497],
                                   [0.384545230792968, 0.684359638026524, 0.761658352980881],
                                   [0.619217161453977, 0.393185162244204, 0.903052400010577],
                                   [0.417471006072039, 0.533073713807993, 0.463944695706918],
                                   [0.115399823228415, 0.0569099984446966, 0.558958747945756],
                                   [0.171625531948228, 0.157836026375844, 0.541086838869235],
                                   [0.369350051552598, 0.636119572284037, 0.170031760925672],
                                   [0.674531606187732, 0.646771697987718, 0.430845370550325],
                                   [0.695369819399195, 0.842777230902543, 0.0669847995909036]])

        xyz = rgb_to_xyz(self.rgb_data, 'p3d65')
        np.testing.assert_almost_equal(xyz, xyz_p3d65_data, decimal=10)

    def test_p3dci(self) -> None:
        xyz_p3dci_data = np.array([[0.321090288528388, 0.151888608776203, 0.303273077932951],
                                   [0.600661498850267, 0.829697485252553, 0.0437032240137313],
                                   [0.362009795602426, 0.689987121696146, 0.635072340146545],
                                   [0.538305467175387, 0.333402912113846, 0.766936302574626],
                                   [0.353400544584638, 0.493110620097379, 0.357650953344360],
                                   [0.0865287091797498, 0.0384952743512069, 0.441386573846148],
                                   [0.125020574972466, 0.115858960930833, 0.424310821621541],
                                   [0.328250459611072, 0.623645560677024, 0.117044740378991],
                                   [0.606336160199604, 0.603905870990017, 0.328254278323778],
                                   [0.656299604855367, 0.839640823081344, 0.0514849211768903]])

        xyz = rgb_to_xyz(self.rgb_data, 'p3dci')
        np.testing.assert_almost_equal(xyz, xyz_p3dci_data, decimal=10)

    def test_bt601(self) -> None:
        xyz_bt601_data = np.array([[0.376511382428339, 0.206128306759390, 0.426021777169841],
                                   [0.675792508151652, 0.847802385080563, 0.145967657808296],
                                   [0.453940519811932, 0.704893890515024, 0.795754806662260],
                                   [0.598091826414390, 0.420783446617844, 0.867182900530435],
                                   [0.475612333747792, 0.575423907199271, 0.526752756491175],
                                   [0.123657353343508, 0.0700944379414749, 0.544995143961394],
                                   [0.203731301180264, 0.194543241701182, 0.546379537446585],
                                   [0.448001245899116, 0.671912858596200, 0.271618433632108],
                                   [0.686130892001755, 0.677855763288555, 0.507010455658811],
                                   [0.722676137461507, 0.859780919969659, 0.179523661390111]])

        xyz = rgb_to_xyz(self.rgb_data, 'bt601')
        np.testing.assert_almost_equal(xyz, xyz_bt601_data, decimal=10)

    def test_bt709(self) -> None:
        xyz_bt709_data = np.array([[0.366017098651803, 0.200620132236861, 0.429911523430599],
                                   [0.676022865795203, 0.848150920226593, 0.135606273325391],
                                   [0.469611943511651, 0.713022505119050, 0.794320826282062],
                                   [0.588752570481395, 0.415813906364358, 0.873696707734848],
                                   [0.479519987489946, 0.577482257459369, 0.524973678879323],
                                   [0.125034772312437, 0.0706715968913314, 0.551067163896759],
                                   [0.206268978590125, 0.195762334755389, 0.550534235820440],
                                   [0.456212147254770, 0.676311617798083, 0.264553940381228],
                                   [0.680478937388771, 0.674989259953595, 0.504588272942317],
                                   [0.720622391743527, 0.858937466998323, 0.169698392701028]])

        xyz = rgb_to_xyz(self.rgb_data, 'bt709')
        np.testing.assert_almost_equal(xyz, xyz_bt709_data, decimal=10)

    def test_bt2020(self) -> None:
        xyz_bt2020_data = np.array([[0.501655026986216, 0.226855521623899, 0.461537962080558],
                                    [0.659467294249460, 0.854096116128317, 0.0348509981969913],
                                    [0.273036996152157, 0.671237004659734, 0.789956592195473],
                                    [0.713482815505430, 0.437261342384889, 0.931488326573436],
                                    [0.428716151679864, 0.568049272483285, 0.510149283748007],
                                    [0.116027332527133, 0.0631484754198461, 0.611137374313120],
                                    [0.180342432859897, 0.186336534568144, 0.592644919655958],
                                    [0.344934531357761, 0.658459842924178, 0.200886036874722],
                                    [0.747548991103156, 0.692003552960989, 0.477694934655075],
                                    [0.733156347549120, 0.870772870988807, 0.0728619295616810]])

        xyz = rgb_to_xyz(self.rgb_data, 'bt2020')
        np.testing.assert_almost_equal(xyz, xyz_bt2020_data, decimal=10)


class TestRgbToRgb(unittest.TestCase):
    def setUp(self) -> None:
        self.rgb_data = np.array([[0.814723686393179, 0.157613081677548, 0.655740699156587],
                                  [0.905791937075619, 0.970592781760616, 0.0357116785741896],
                                  [0.126986816293506, 0.957166948242946, 0.849129305868777],
                                  [0.913375856139019, 0.485375648722841, 0.933993247757551],
                                  [0.632359246225410, 0.800280468888800, 0.678735154857774],
                                  [0.0975404049994095, 0.141886338627215, 0.757740130578333],
                                  [0.278498218867048, 0.421761282626275, 0.743132468124916],
                                  [0.546881519204984, 0.915735525189067, 0.392227019534168],
                                  [0.957506835434298, 0.792207329559554, 0.655477890177557],
                                  [0.964888535199277, 0.959492426392903, 0.171186687811562]])

        return super().setUp()

    def test_srgb_to_p3d65(self) -> None:
        srgb_p3d65_data = np.array([[0.749149517797163, 0.225382160697444, 0.638340907200463],
                                    [0.917740353963161, 0.968533202347514, 0.320518832943416],
                                    [0.452702659123348, 0.943262104061097, 0.851313685324364],
                                    [0.857136582325399, 0.507569941282566, 0.910414106774722],
                                    [0.666252729338138, 0.795432613142980, 0.687742109158453],
                                    [0.106688238223912, 0.140633599511496, 0.727579223792828],
                                    [0.309899052945869, 0.417942602257574, 0.720623172551372],
                                    [0.633654908980644, 0.906511288849161, 0.461125631892061],
                                    [0.930953008430081, 0.798430640540624, 0.673209623305623],
                                    [0.963933440264574, 0.959672190994730, 0.356276106849133]])

        rgb = rgb_to_rgb(self.rgb_data, rgb_from='sRGB', rgb_to='DisplayP3')
        np.testing.assert_almost_equal(rgb, srgb_p3d65_data, decimal=10)

    def test_argb_to_601(self) -> None:
        argb_601_data = np.array([[0.921149259154151, 0.0772530237187067, 0.641712532133909],
                                  [0.872073373409080, 0.967999900735555, 0],
                                  [0, 0.953387083553200, 0.828666361384348],
                                  [1, 0.438297594954419, 0.947469016534625],
                                  [0.521549627469207, 0.782469902743523, 0.641620891929595],
                                  [0.0151971191522830, 0.0613030092783056, 0.756063902907032],
                                  [0.126644689364697, 0.368534576526877, 0.734517461153898],
                                  [0.244438757640037, 0.908279636968565, 0.271053635990722],
                                  [1, 0.773666209685757, 0.615022991772988],
                                  [0.963775769757160, 0.955918304186196, 0]])

        rgb = rgb_to_rgb(self.rgb_data, rgb_from='AdobeRGB', rgb_to='bt601', clip_method='clip')
        np.testing.assert_almost_equal(rgb, argb_601_data, decimal=10)


class TestRgbToYCbCr(unittest.TestCase):
    def setUp(self) -> None:
        self.rgb_data = np.array([[0.814723686393179, 0.157613081677548, 0.655740699156587],
                                  [0.905791937075619, 0.970592781760616, 0.0357116785741896],
                                  [0.126986816293506, 0.957166948242946, 0.849129305868777],
                                  [0.913375856139019, 0.485375648722841, 0.933993247757551],
                                  [0.632359246225410, 0.800280468888800, 0.678735154857774],
                                  [0.0975404049994095, 0.141886338627215, 0.757740130578333],
                                  [0.278498218867048, 0.421761282626275, 0.743132468124916],
                                  [0.546881519204984, 0.915735525189067, 0.392227019534168],
                                  [0.957506835434298, 0.792207329559554, 0.655477890177557],
                                  [0.964888535199277, 0.959492426392903, 0.171186687811562]])

        return super().setUp()

    def test_srgb_709(self) -> None:
        srgb_bt709_data = np.array([[0.281805692859469, 0.181368631563244, 0.324676836849213],
                                    [0.882612430791199, -0.468944897957552, 0.00748596121556643],
                                    [0.754905390434227, 0.0411593781144257, -0.437266372691735],
                                    [0.569611713301053, 0.192022740860807, 0.211621094860688],
                                    [0.728302050361373, -0.0457272798826113, -0.0859802849295751],
                                    [0.119217710482599, 0.329236825625150, -0.0481417641000848],
                                    [0.360393865410084, 0.190597397932652, -0.0905283565103040],
                                    [0.778273947072352, -0.238363842010879, -0.176415087756900],
                                    [0.796486316285880, -0.0961518974478026, 0.0989237066647022],
                                    [0.894762380787847, -0.423287727037390, 0.0417760068805468]])

        yuv = rgb_to_ycbcr(self.rgb_data, 'sRGB', 'bt709')
        np.testing.assert_almost_equal(yuv, srgb_bt709_data, decimal=10)

    def test_p3d65_2020(self) -> None:
        p3d65_bt2020_data = np.array([[0.353754057682567, 0.137586779863792, 0.236972187165147],
                                      [0.887539367910214, -0.428216224666565, 0.000455698778348219],
                                      [0.800374089530253, 0.0178831126039403, -0.230071700531714],
                                      [0.596114692003952, 0.171990088874905, 0.161031264004648],
                                      [0.726249074517154, -0.0426418894184999, -0.0610082310712587],
                                      [0.153230171471444, 0.303451411853502, -0.00373055716738739],
                                      [0.368456066012157, 0.181427057824085, -0.0510488867924536],
                                      [0.779284376991642, -0.226166395729829, -0.122309574942371],
                                      [0.800721926887752, -0.0958332202960569, 0.0709790987216473],
                                      [0.898860286809442, -0.394318867910459, 0.0258274958937025]])

        yuv = rgb_to_ycbcr(self.rgb_data, 'DisplayP3', 'bt2020')
        np.testing.assert_almost_equal(yuv, p3d65_bt2020_data, decimal=10)

    def test_argb_601(self) -> None:
        argb_601_data = np.array([[0.393926382073238, 0.139834170463133, 0.376050554265987],
                                  [0.828965880381086, -0.467813702246662, 0.0307471419600533],
                                  [0.654106183243544, 0.0985102585444717, -0.466552199175138],
                                  [0.664292156123191, 0.159806354633992, 0.239449246702431],
                                  [0.688397953203715, -0.0263978901095484, -0.119007365003215],
                                  [0.126720090004300, 0.355160165294996, -0.0795456282824655],
                                  [0.337931549112866, 0.223806948104420, -0.150703894256896],
                                  [0.637147449937861, -0.206599217803126, -0.280106057273769],
                                  [0.823254686147660, -0.117512242875097, 0.126066557669287],
                                  [0.849292999714688, -0.479284988552307, 0.0816567546665282]])

        yuv = rgb_to_ycbcr(self.rgb_data, rgb='AdobeRGB', ycbcr='bt601', clip_method='clip')
        np.testing.assert_almost_equal(yuv, argb_601_data, decimal=10)