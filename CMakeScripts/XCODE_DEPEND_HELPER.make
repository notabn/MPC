# DO NOT EDIT
# This makefile makes sure all linkable targets are
# up-to-date with anything they link to
default:
	echo "Do not invoke directly"

# Rules to remove targets that are older than anything to which they
# link.  This forces Xcode to relink the targets from scratch.  It
# does not seem to check these dependencies itself.
PostBuild.mpc.Debug:
/Users/emilbalcu/Courses/Udacity/NanodegreeSDC/Term_2/MPC/Debug/mpc:
	/bin/rm -f /Users/emilbalcu/Courses/Udacity/NanodegreeSDC/Term_2/MPC/Debug/mpc


PostBuild.mpc.Release:
/Users/emilbalcu/Courses/Udacity/NanodegreeSDC/Term_2/MPC/Release/mpc:
	/bin/rm -f /Users/emilbalcu/Courses/Udacity/NanodegreeSDC/Term_2/MPC/Release/mpc


PostBuild.mpc.MinSizeRel:
/Users/emilbalcu/Courses/Udacity/NanodegreeSDC/Term_2/MPC/MinSizeRel/mpc:
	/bin/rm -f /Users/emilbalcu/Courses/Udacity/NanodegreeSDC/Term_2/MPC/MinSizeRel/mpc


PostBuild.mpc.RelWithDebInfo:
/Users/emilbalcu/Courses/Udacity/NanodegreeSDC/Term_2/MPC/RelWithDebInfo/mpc:
	/bin/rm -f /Users/emilbalcu/Courses/Udacity/NanodegreeSDC/Term_2/MPC/RelWithDebInfo/mpc




# For each target create a dummy ruleso the target does not have to exist
